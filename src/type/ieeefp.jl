const log2_log10 = log(2)/log(10);
const log10_log2 = log(10)/log(2);

safe_bits2digs(nbits::Int) = floor(Int, nbits * log2_log10)
safe_digs2bits(ndigs::Int) = floor(Int, ndigs * log10_log2)

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
ufp(x::Integer, base::Int=2) = ufp(Float64(x), base)
function ufp{P}(x::ArbFloat{P}, base::Int=2)
   z = pfp(x, base)
   return Float64(base)^z
end
"ufp2 is unit_first_place in base 2"
ufp2{T<:Real}(x::T) = 2.0^pfp2(x)
ufp2{P}(x::ArbFloat{P}) = 2.0^pfp2(x)
"ufp10 is unit_first_place in base 10"
ufp10{T<:Real}(x::T) = 10.0^pfp10(x)
ufp10{P}(x::ArbFloat{P}) = 10.0^pfp10(x)

"""
ulp   is unit_last_place
ulp2  is unit_last_place base 2
"""
function ulp2(x::Real, precision::Int)
   unitfp = ufp2(x)
   twice_u = 2.0^(1-precision)
   return twice_u * unitfp
end
ulp2{T<:AbstractFloat}(x::T)  = ulp2(x, 1+Base.significand_bits(T))
ulp2{P}(x::ArbFloat{P},) = ulp2(x, P)
"""ulp10 is unit_last_place base 10"""
function ulp10(x::Real, bitprecision::Int)
    unitfp = ufp10(x)
    digitprecision = safe_bits2digs(bitprecision)
    twice_u = 10.0^(1-digitprecision)
    return twice_u * unitfp
end
ulp10{T<:AbstractFloat}(x::T) = ulp10( x, (1+Base.significand_bits(T)) )
ulp10{P}(x::ArbFloat{P}) = ulp10(x, P)
