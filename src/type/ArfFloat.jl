
            # P is the precision used for this value
type ArfFloat{P}  <: Real
  exponent::Int # fmpz
  words_sgn::UInt # mp_size_t
  mantissa1::UInt # mantissa_struct
  mantissa2::UInt
end

precision{P}(x::ArfFloat{P}) = P
precision{P}(::Type{ArfFloat{P}}) = P

precision(::Type{ArfFloat}) = ArbFloatPrecision[1]
setprecision(::Type{ArfFloat}, x::Int) = setprecision(ArbFloat, x)




# a type specific hash function helps the type to 'just work'
const hash_arffloat_lo = (UInt === UInt64) ? 0x37e642589da3416a : 0x5d46a6b4
const hash_0_arffloat_lo = hash(zero(UInt), hash_arffloat_lo)
hash{P}(z::ArfFloat{P}, h::UInt) =
    hash(reinterpret(UInt,z.mantissa1)$z.exponent,
         (h $ hash(z.mantissa2$(~reinterpret(UInt,P)), hash_arffloat_lo) $ hash_0_arffloat_lo))


function clearArfFloat{P}(x::ArfFloat{P})
     ccall(@libarb(arf_clear), Void, (Ptr{ArfFloat{P}},), &x)
end

function initializer{P}(::Type{ArfFloat{P}})
    z = ArfFloat{P}(0,0,0,0)
    ccall(@libarb(arf_init), Void, (Ptr{ArfFloat{P}},), &z)
    finalizer(z, clearArfFloat)
    z
end

function convert{P}(::Type{BigFloat}, x::ArfFloat{P})
    z = zero(BigFloat)
    ccall(@libarb(arf_get_mpfr), Void, (Ptr{BigFloat}, Ptr{ArfFloat{P}}), &z, &x)
    z
end

function convert{P}(::Type{ArfFloat{P}}, x::BigFloat)
    z = initializer(ArfFloat{P})
    ccall(@libarb(arf_set_mpfr), Void, (Ptr{ArfFloat{P}}, Ptr{BigFloat}), &z, &x)
    z
end

midpoint{P}(x::ArfFloat{P}) = x

radius{P}(x::ArfFloat{P}) = zero(ArfFloat{P})

function frexp{P}(x::ArfFloat{P})
   mantissa = initializer(ArfFloat{P})
   exponent = zero(Int64)
   ccall(@libarb(arf_frexp), Void, (Ptr{ArfFloat{P}}, Int64, Ptr{ArfFloat{P}}), &mantissa, exponent, &x)
   mantissa, exponent
end

