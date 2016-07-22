#=
            # P is the precision used for this value
type ArfFloat{P}  <: Real
  exponentOf2::Int # fmpz
  nwords_sign::UInt # mp_size_t
  significand1::UInt # significand_struct
  significand2::UInt
end
=#

precision{P}(x::ArfFloat{P}) = P
precision{P}(::Type{ArfFloat{P}}) = P
precision(::Type{ArfFloat}) = ArbFloatPrecision[1]
setprecision(::Type{ArfFloat}, x::Int) = setprecision(ArbFloat, x)


# a type specific hash function helps the type to 'just work'
const hash_arffloat_lo = (UInt === UInt64) ? 0x37e642589da3416a : 0x5d46a6b4
const hash_0_arffloat_lo = hash(zero(UInt), hash_arffloat_lo)
hash{P}(z::ArfFloat{P}, h::UInt) =
    hash(reinterpret(UInt,z.significand1)$z.exponentOf2,
         (h $ hash(z.significand2$(~reinterpret(UInt,P)), hash_arffloat_lo) $ hash_0_arffloat_lo))

@inline finalize{P}(x::ArfFloat{P}) =  ccall(@libarb(arf_clear), Void, (Ptr{ArfFloat{P}},), &x)
@inline initial0{P}(x::ArfFloat{P}) =  ccall(@libarb(arf_init), Void, (Ptr{ArfFloat{P}},), &x)

# initialize and zero a variable of type ArfFloat
function initializer{T<:ArfFloat}(::Type{T})
    P = precision(T)
    z = ArfFloat{P}(0,0,0,0)
    initial0(z)
    finalizer(z, finalize)
    return z
end
initializer(::Type{ArfFloat}) = initializer{ArfFloat{precision{ArfFloat}}}
# empty constructor
ArfFloat() = initializer(ArfFloat{precision(ArfFloat)})

zero{T<:ArfFloat}(::Type{T}) = initializer(T)

function one{T<:ArfFloat}(::Type{T})
    z = initializer(T)
    z.exponentOf2 = 1
    z.nwords_sign = 2
    z.significand1 =  one(UInt) + ((-1 % UInt)>>1)
    return z
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
convert(::Type{ArfFloat}, x::BigFloat) = convert(ArfFloat{precision(ArfFloat)}, x)

midpoint{P}(x::ArfFloat{P}) = x

radius{P}(x::ArfFloat{P}) = zero(ArfFloat{P})



#=
function frexp{P}(x::ArfFloat{P})
   significand = initializer(ArfFloat{P})
   exponentOf2 = zero(Int64)
   ccall(@libarb(arf_frexp), Void, (Ptr{ArfFloat{P}}, Int64, Ptr{ArfFloat{P}}), &significand, exponentOf2, &x)
   significand, exponentOf2
end
=#
