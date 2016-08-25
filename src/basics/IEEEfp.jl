#=

prec=precision(midpt); # bits of significand (signficant radix-2 digits
prec, typeof(midpt)
# (57,ArbFloats.ArbFloat{57})

1 + round(Int,log2(ufp2(midpt))) -  round(Int,log2(ulp2(midpt)))
# 57

prec == (1 + round(Int,log2(ufp2(midpt))) -  round(Int,log2(ulp2(midpt))))
# true

=#



"""
   x.midpoint -> (significand, exponentOf2)
                  [0.5,1.0)     2^expo
   x.radius   -> (radial significand, radial exponentOf2)
"""
function frexp{P}(x::ArfFloat{P})
    exponentOf2 = x.exponentOf2
    significand = deepcopy(x)
    significand.exponentOf2 = 0
    return significand, exponentOf2
end

function ldexp{P}(s::ArfFloat{P}, e::Int)
    z = deepcopy(s)
    z.exponentOf2 = e
    return z
end

function frexp{P}(x::ArbFloat{P})
    significand, exponentOf2 = frexp(ArfFloat{P}(x))
    return ArbFloat{P}(significand), exponentOf2
end

function ldexp{P}(s::ArbFloat{P}, e::Int)
    z = deepcopy(s)
    z.exponentOf2 = e
    return z
end
ldexp{P}(x::Tuple{ArbFloats.ArbFloat{P}, Int}) = ldexp(x[1],x[2])


#=


      gte_bits2digs(b_bits)    ~>  d_digits
      d_digits | d digits suffice to encode and recover b bits without error

      gte_digs2bits(d_digits)  ~>  b_bits
      b_bits |  b bits suffice to encode and recover d digits without error

      lte_bits2digs(b_bits)    ~>  c_digits
      c_digits | b bits are necessary encode and recover c digits without error

      lte_digs2bits(d_digits)  ~>  a_bits
      a_bits |  d digits are necessary encode and recover a bits without error

      lte_digs2bits( gte_bits2digs(b_bits  ) ) == b_bits
      lte_bits2digs( gte_digs2bits(d_digits) ) == d_digits

const log2_log10 = log(10,2)  # 0.3010299956639812 ~= log(2)/log(10)
const log10_log2 = log(2,10)  # 3.321928094887362  ~= log(10)/log(2)

lte_bits2digs(nbits::Int) = floor(Int, nbits * log2_log10)
lte_digs2bits(ndigs::Int) = floor(Int, ndigs * log10_log2)
=#

lte_bits2digs(nbits::Int) = floor( Int, nbits * 0.30102999566398125 ) # log(10,2) RoundUp
gte_bits2digs(nbits::Int)  = ceil( Int, nbits * 0.3010299956639812  ) # log(10,2) RoundDown
lte_digs2bits(ndigs::Int) = floor( Int, ndigs * 3.3219280948873626  ) # log(2,10) RoundUp
gte_digs2bits(ndigs::Int)  = ceil( Int, ndigs * 3.3219280948873617  ) # log(2,10) RoundDown




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
log_base{T<:ArbFloat}(x::T, base::Int) = ArbFloats.logbase(x,base)


#=
    position_first_place: the radix position of the most significant nonzero bit|digit

    pfp{T<:AbstractFloat}(x::T, base::Int=2)
    pfp{T<:AbstractFloat}(x::T)              == pfp(x,  2)  ==  pfp2{T<:AbstractFloat}(x::T)
    pfp{T<:AbstractFloat}(x::T, base=10)     == pfp(x, 10)  ==  pfp10{T<:AbstractFloat}(x::T)

    position_last_place: the radix position of the least significant nonzero bit|digit

    plp{T<:AbstractFloat}(x::T, base::Int=2)
    plp{T<:AbstractFloat}(x::T)              == p;p(x,  2)  ==  plp2{T<:AbstractFloat}(x::T)
    plp{T<:AbstractFloat}(x::T, base=10)     == plp(x, 10)  ==  p;p10{T<:AbstractFloat}(x::T)

    unit_first_place: the radix *value) of the most significant nonzero bit|digit

    pfp{T<:AbstractFloat}(x::T, base::Int=2)
    pfp{T<:AbstractFloat}(x::T)              == pfp(x,  2)  ==  pfp2{T<:AbstractFloat}(x::T)
    pfp{T<:AbstractFloat}(x::T, base=10)     == pfp(x, 10)  ==  pfp10{T<:AbstractFloat}(x::T)

    unit_last_place: the radix *value* of the least significant nonzero bit|digit

    plp{T<:AbstractFloat}(x::T, base::Int=2)
    plp{T<:AbstractFloat}(x::T)              == plp(x,  2)  ==  plp2{T<:AbstractFloat}(x::T)
    plp{T<:AbstractFloat}(x::T, base=10)     == plp(x, 10)  ==  plp10{T<:AbstractFloat}(x::T)

=#

"""
position_first_place
determine the position of the most significant nonzero bit|digit
"""
function pfp{T<:Real}(x::T, base::Int=2)
   z = 0 # if x==0.0
   if notzero(x)
       z = floor( Int, log_base(abs(x), base) )
   end
   return z
end
pfp{P}(x::ArbFloat{P}, base::Int=2) =
    return iszero(x) ? 0 : floor( Int, log_base(abs(x), base) )
"""
binary position_first_place
determine the position of the most significant nonzero bit
"""
pfp2{T<:Real}(x::T) = (x==zero(T) ? 0 : floor( Int, log2(abs(x)) ))
pfp2{P}(x::ArbFloat{P}) = (iszero(x) ? 0 : floor( Int, log2(abs(x)) ))
"""
decimal position_first_place
determine the position of the most significant nonzero digit
"""
pfp10{T<:Real}(x::T) = (x==zero(T) ? 0 : floor( Int, log10(abs(x)) ))
pfp10{P}(x::ArbFloat{P}) = (iszero(x) ? 0 : floor( Int, log10(abs(x)) ))

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
   unitfp  = ufp2(x)
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
   unitfp  = ufp2(x)
   twice_u = 2.0^(1-precision)
   return (*)(promote(twice_u, unitfp)...)
end
function ulp2{P}(x::ArbFloat{P})
   unitfp  = ufp2(x)
   twice_u = 2.0^(1-P)
   return (*)(promote(twice_u, unitfp)...)
end
ulp2{T<:AbstractFloat}(x::T)  = ulp2(x, 1+Base.significand_bits(T))
ulp2(x::Integer) = ulp2(Float64(x))

"""ulp10 is unit_last_place base 10"""
function ulp10(x::Real, bitprecision::Int)
    unit10fp = ufp10(x)
    digitprecision = lte_bits2digs(bitprecision)
    twice_u10 = 10.0^(1-digitprecision)
    return twice_u10 * unit10fp
end
function ulp10{P}(x::ArbFloat{P})
    unit10fp = ufp10(x)
    digitprecision = lte_bits2digs(P)
    twice_u10 = 10.0^(1-digitprecision)
    return twice_u10 * unit10fp
end
ulp10{T<:AbstractFloat}(x::T) = ulp10( x, (1+Base.significand_bits(T)) )
ulp10(x::Integer) = ulp10(Float64(x))


function eps{T<:ArbFloat}(x::T)
    ieps = internal_eps(x)
    return T(ieps)
end
eps{P}(x::ArbFloat{P}) = ArbFloat{P}( internal_eps(x) )
eps{T<:ArbFloat}(::Type{T}) = T(internal_eps(T))

internal_eps{T<:ArbFloat}(::Type{T}) = ldexp(0.5,1-precision(T)) # for intertype workings
internal_eps{P}(::Type{ArbFloat{P}}) = ldexp(0.5,1-P) # for intertype workings
function internal_eps{P}(x::ArbFloat{P})              # for intratype workings
    m,r = midpoint(x), radius(x)
    z =
        if iszero(m)
            if iszero(r)
               ldexp(0.5, 1-P)
            else
               ufp2(r)
            end
        elseif iszero(r)
            ulp2(m)
        else
            max( ulp2(m), ufp2(r) )
        end
   return z
end

function nextfloat{P}(x::ArbFloat{P})
    x + ulp2(x)
end

function prevfloat{P}(x::ArbFloat{P})
    x - ulp2(x)
end
