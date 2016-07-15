
"""
   x.midpoint -> (significand, exponent)
                  [0.5,1.0)     2^expo
   x.radius   -> (radial significand, radial exponent)
"""
function frexp{P}(x::ArfFloat{P})
    exponent    = x.exponent
    significand = deepcopy(x)
    significand.exponent = 0
    return significand, exponent
end

function ldexp{P}(s::ArfFloat{P}, e::Int)
    z = deepcopy(s)
    z.exponent = e
    return z
end

function frexp{P}(x::ArbFloat{P})
    significand, exponent = frexp(ArfFloat{P}(x))
    return ArbFloat{P}(significand), exponent
end

function ldexp{P}(s::ArbFloat{P}, e::Int)
    z = deepcopy(s)
    z.exponent = e
    return z
end



#=
const log2_log10 = log(10,2)  # 0.3010299956639812 ~= log(2)/log(10)
const log10_log2 = log(2,10)  # 3.321928094887362  ~= log(10)/log(2)

lte_bits2digs(nbits::Int) = floor(Int, nbits * log2_log10)
lte_digs2bits(ndigs::Int) = floor(Int, ndigs * log10_log2)
=#

lte_bits2digs(nbits::Int) = floor( Int, nbits * 0.3010299956639812 )
lte_digs2bits(ndigs::Int) = floor( Int, ndigs * 3.321928094887362  )
gte_bits2digs(nbits::Int)  = ceil( Int, nbits * 0.3010299956639812 )
gte_digs2bits(ndigs::Int)  = ceil( Int, ndigs * 3.321928094887362  )

"""
logarithm_base(x)
"""
function log_base(x::Real, base::Int)
   z = if base == 2
           log2(x)
        elseif base == 10
           log10(x)
        else
           log(x) / log(base)
        end
   return z
end
log_base{P}(x::ArbFloat{P}, base::Int) = ArbFloats.logbase(x,base)

"""
position_first_place
determine the position of the most significant nonzero bit|digit
"""
function pfp{T<:Real}(x::T, base::Int=2)
   z = 0 # if x==0.0
   if x != zero(T)
       z = floor( Int, log_base(abs(x), base) )
   end
   return z
end
pfp{P}(x::ArbFloat{P}, base::Int=2) =
    x==zero(ArbFloat{P}) ? 0 : floor( Int, log_base(abs(x), base) )
"""
binary position_first_place
determine the position of the most significant nonzero bit
"""
pfp2{T<:Real}(x::T) = x==zero(T) ? 0 : floor( Int, log2(abs(x)) )
pfp2{P}(x::ArbFloat{P}) =
    x==zero(ArbFloat{P}) ? 0 : floor( Int, log2(abs(x)) )
"""
decimal position_first_place
determine the position of the most significant nonzero digit
"""
pfp10{T<:Real}(x::T) = x==zero(T) ? 0 : floor( Int, log10(abs(x)) )
pfp10{P}(x::ArbFloat{P}) =
    x==zero(ArbFloat{P}) ? 0 : floor( Int, log10(abs(x)) )

"""
ufp is unit_first_place
the float value given by a 1 at the position of
  the most significant nonzero bit|digit in _x_
"""
function ufp(x::AbstractFloat, base::Int=2)
   z = pfp(x, base)
   b = convert(Float64, base)
   return b^z
end
function ufp{P}(x::ArbFloat{P}, base::Int=2)
   z = pfp(x, base)
   return Float64(base)^z
end
ufp(x::Integer, base::Int=2) = ufp(Float64(x), base)
"ufp2 is unit_first_place in base 2"
ufp2{T<:Real}(x::T) = 2.0^pfp2(x)
ufp2{P}(x::ArbFloat{P}) = 2.0^pfp2(x)
ufp2(x::Integer) = ufp2(Float64(x))
"ufp10 is unit_first_place in base 10"
ufp10{T<:Real}(x::T) = 10.0^pfp10(x)
ufp10{P}(x::ArbFloat{P}) = 10.0^pfp10(x)
ufp10(x::Integer) = ufp10(Float64(x))
"""
ulp   is unit_last_place
the float value given by a 1 at the position of
  the least significant nonzero bit|digit in _x_
"""
function ulp(x::Real, precision::Int, base::Int)
   unitfp = ufp2(x)
   twice_u = 2.0^(1-precision)
   return twice_u * unitfp
end
ulp{T<:AbstractFloat}(x::T, base::Int=2)  =
    ulp(x, 1+Base.significand_bits(T), base)
ulp{P}(x::ArbFloat{P}, base::Int=2)  =
    ulp(x, P, base)
ulp(x::Integer, base::Int=2) = ulp(Float64(x), base)

"""ulp2  is unit_last_place base 2"""
function ulp2(x::Real, precision::Int)
   unitfp = ufp2(x)
   twice_u = 2.0^(1-precision)
   return twice_u * unitfp
end
function ulp2{P}(x::ArbFloat{P})
   unitfp = ufp2(x)
   twice_u = 2.0^(1-P)
   return twice_u * unitfp
end
ulp2{T<:AbstractFloat}(x::T)  = ulp2(x, 1+Base.significand_bits(T))
ulp2(x::Integer) = ulp2(Float64(x))

"""ulp10 is unit_last_place base 10"""
function ulp10(x::Real, bitprecision::Int)
    unitfp = ufp10(x)
    digitprecision = lte_bits2digs(bitprecision)
    twice_u = 10.0^(1-digitprecision)
    return twice_u * unitfp
end
function ulp10{P}(x::ArbFloat{P})
    unitfp = ufp10(x)
    digitprecision = lte_bits2digs(P)
    twice_u = 10.0^(1-digitprecision)
    return twice_u * unitfp
end
ulp10{T<:AbstractFloat}(x::T) = ulp10( x, (1+Base.significand_bits(T)) )
ulp10(x::Integer) = ulp10(Float64(x))


eps{P}(::Type{ArbFloat{P}}) = ldexp(0.5,1-P) # for intertype workings
function eps{P}(x::ArbFloat{P})              # for intratype workings
    m = midpoint(x)
    iszero(m) && return eps(ArbFloat{P})
    max( ulp2(m), ufp2(radius(x)) )
end

