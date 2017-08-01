#=
            # P is the precision used for this value
type ArfFloat{P}  <: Real
  exponentOf2::Int # fmpz
  nwords_sign::UInt # mp_size_t
  significand1::UInt # significand_struct
  significand2::UInt
end
=#

precision(x::ArfFloat{P}) where {P} = P
precision(::Type{ArfFloat{P}}) where {P} = P
precision(::Type{ArfFloat}) = ArbFloatPrecision[1]
setprecision(::Type{ArfFloat}, x::Int) = setprecision(ArbFloat, x)

# a type specific hash function helps the type to 'just work'
const hash_arffloat_lo = (UInt === UInt64) ? 0x37e642589da3416a : 0x5d46a6b4
const hash_0_arffloat_lo = hash(zero(UInt), hash_arffloat_lo)
hash(z::ArfFloat{P}, h::UInt) where {P} =
    hash(reinterpret(UInt,z.significand1)$z.exponentOf2,
         (h $ hash(z.significand2$(~reinterpret(UInt,P)), hash_arffloat_lo) $ hash_0_arffloat_lo))


weakcopy(x::ArfFloat{P}) where {P} = WeakRef(x)

function copy(x::ArfFloat{P}) where {P}
    z = initializer(ArfFloat{P})
    ccall(@libarb(arf_set), Void, (Ptr{ArfFloat{P}}, Ptr{ArfFloat{P}}), &z, &x)
    return z
end

# initialize and zero a variable of type ArfFloat
function release(x::ArfFloat{P}) where {P}
    ccall(@libarb(arf_clear), Void, (Ptr{ArfFloat{P}}, ), &x)
    return nothing
end

function initializer(::Type{ArfFloat{P}}) where {P}
    z = ArfFloat{P}(zero(Int), zero(UInt64), zero(Int64), zero(Int64))
    ccall(@libarb(arf_init), Void, (Ptr{ArfFloat{P}}, ), &z)
    finalizer(z, release)
    return z
end

# empty constructor
@inline function ArfFloat() 
     P = precision(ArfFloat)
     return initializer(ArfFloat{P})
end            

function deepcopy(x::ArfFloat{P}) where {P}
    z = initializer(ArfFloat{P})
    ccall(@libarb(arf_set), Void, (Ptr{ArfFloat{P}}, Ptr{ArfFloat{P}}), &z, &x)
    return z
end

function zero(::Type{ArfFloat{P}}) where {P}
    z = initializer( ArbFloat{P} )
    ccall(@libarb(arf_zero), Void, (Ptr{ArfFloat{P}}, ), &z)
    return z
end

function one(::Type{ArfFloat{P}}) where {P}
    z = initializer( ArbFloat{P} )
    ccall(@libarb(arf_one), Void, (Ptr{ArfFloat{P}}, ), &z)
    return z
end


function isnan(x::T) where {T <: ArfFloat}
    zero(Cint) != ccall(@libarb(arf_is_nan), Cint, (Ptr{T},), &x)
end
function isinf(x::T) where {T <: ArfFloat}
    zero(Cint) != ccall(@libarb(arf_is_inf), Cint, (Ptr{T},), &x)
end
function isposinf(x::T) where {T <: ArfFloat}
    zero(Cint) != ccall(@libarb(arf_is_pos_inf), Cint, (Ptr{T},), &x)
end
function isneginf(x::T) where {T <: ArfFloat}
    zero(Cint) != ccall(@libarb(arf_is_neg_inf), Cint, (Ptr{T},), &x)
end
function iszero(x::T) where {T <: ArfFloat}
    zero(Cint) != ccall(@libarb(arf_is_zero), Cint, (Ptr{T},), &x)
end
function isone(x::T) where {T <: ArfFloat}
    zero(Cint) != ccall(@libarb(arf_is_one), Cint, (Ptr{T},), &x)
end
function isfinite(x::T) where {T <: ArfFloat}
    zero(Cint) != ccall(@libarb(arf_is_finite), Cint, (Ptr{T},), &x)
end
function isnormal(x::T) where {T <: ArfFloat}
    zero(Cint) != ccall(@libarb(arf_is_normal), Cint, (Ptr{T},), &x)
end
function isspecial(x::T) where {T <: ArfFloat}
    zero(Cint) != ccall(@libarb(arf_is_special), Cint, (Ptr{T},), &x)
end

function notnan(x::T) where {T <: ArfFloat}
    zero(Cint) == ccall(@libarb(arf_is_nan), Cint, (Ptr{T},), &x)
end
function notinf(x::T) where {T <: ArfFloat}
    zero(Cint) == ccall(@libarb(arf_is_inf), Cint, (Ptr{T},), &x)
end
function notposinf(x::T) where {T <: ArfFloat}
    zero(Cint) == ccall(@libarb(arf_is_pos_inf), Cint, (Ptr{T},), &x)
end
function notneginf(x::T) where {T <: ArfFloat}
    zero(Cint) == ccall(@libarb(arf_is_neg_inf), Cint, (Ptr{T},), &x)
end
function notzero(x::T) where {T <: ArfFloat}
    zero(Cint) == ccall(@libarb(arf_is_zero), Cint, (Ptr{T},), &x)
end
function notone(x::T) where {T <: ArfFloat}
    zero(Cint) == ccall(@libarb(arf_is_one), Cint, (Ptr{T},), &x)
end
function notfinite(x::T) where {T <: ArfFloat}
    zero(Cint) == ccall(@libarb(arf_is_finite), Cint, (Ptr{T},), &x)
end
function notnormal(x::T) where {T <: ArfFloat}
    zero(Cint) == ccall(@libarb(arf_is_normal), Cint, (Ptr{T},), &x)
end
function notspecial(x::T) where {T <: ArfFloat}
    zero(Cint) == ccall(@libarb(arf_is_special), Cint, (Ptr{T},), &x)
end


function convert(::Type{BigFloat}, x::ArfFloat{P}) where {P}
    z = BigFloat(0)
    r = ccall(@libarb(arf_get_mpfr), Int, (Ptr{BigFloat}, Ptr{ArfFloat{P}}, Cint), &z, &x, 0)
    return z
end

function convert(::Type{ArfFloat{P}}, x::BigFloat) where {P}
    z = initializer(ArfFloat{P})
    ccall(@libarb(arf_set_mpfr), Void, (Ptr{ArfFloat{P}}, Ptr{BigFloat}), &z, &x)
    z
end
convert(::Type{ArfFloat}, x::BigFloat) = convert(ArfFloat{precision(ArfFloat)}, x)

convert(::Type{T}, x::BigInt) where {T <: ArfFloat} = convert(T, convert(BigFloat, x))
convert(::Type{ArfFloat{P}}, x::BigInt) where {P} = convert(ArfFloat{P}, convert(BigFloat, x))

function convert(::Type{ArfFloat{P}}, x::Int64) where {P}
    z = initializer(ArfFloat{P})
    ccall(@libarb(arf_set_si), Void, (Ptr{ArfFloat{P}}, Ptr{Int64}), &z, &x)
    z
end
convert(::Type{ArfFloat}, x::Int64) = convert(ArfFloat{precision(ArfFloat)}, x)

function convert(::Type{ArfFloat{P}}, x::Float64) where {P}
    z = initializer(ArfFloat{P})
    ccall(@libarb(arf_set_d), Void, (Ptr{ArfFloat{P}}, Ptr{Float64}), &z, &x)
    z
end
function convert(::Type{ArfFloat}, x::Float64)
     P = precision(ArfFloat)
     return convert(ArfFloat{P}, x)
end            

midpoint(x::ArfFloat{P}) where {P} = x

radius(x::ArfFloat{P}) where {P} = ArfFloat{P}(0)


#=
#define ARF_RND_DOWN FMPR_RND_DOWN
#define ARF_RND_UP FMPR_RND_UP
#define ARF_RND_FLOOR FMPR_RND_FLOOR
#define ARF_RND_CEIL FMPR_RND_CEIL
#define ARF_RND_NEAR FMPR_RND_NEAR
=#

function round(x::T, prec::Int64) where {T <: ArfFloat}
    P = precision(T)
    z = ArfFloat{P}()
    ccall(@libarb(arf_set_round), Int, (Ptr{T}, Ptr{T}, Int64, Int), &z, &x, prec, 2)
    return z
end


#=
function frexp{P}(x::ArfFloat{P})
   significand = ArfFloat{P}()
   exponentOf2 = zero(Int64)
   ccall(@libarb(arf_frexp), Void, (Ptr{ArfFloat{P}}, Int64, Ptr{ArfFloat{P}}), &significand, exponentOf2, &x)
   significand, exponentOf2
end
=#

function min(x::T, y::T) where {T <: ArfFloat}
    c = ccall(@libarb(arf_cmp), Cint, (Ptr{T}, Ptr{T}), &x, &y)
    return (c < 0) ? x : y
end

function max(x::T, y::T) where {T <: ArfFloat}
    c = ccall(@libarb(arf_cmp), Cint, (Ptr{T}, Ptr{T}), &x, &y)
    return (c > 0) ? x : y
end
