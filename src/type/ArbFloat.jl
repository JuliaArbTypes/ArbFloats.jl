#=
            # P is the precision used with the typed occurance
            #
type ArbFloat{P}  <: Real     # field and struct names from arb.h
  exponentOf2        ::Int    #           fmpz
  nwords_sign        ::UInt   #           mp_size_t
  significand1       ::UInt   #           significand_struct
  significand2       ::UInt   #
  radius_exponentOf2 ::Int    #           fmpz
  radius_significand ::UInt   #
end
=#

for T in (:String, :Int32, :Int64, :Float32, :Float64, :BigInt, :BigFloat)
   @eval ArbFloat(x::$T, p::Int) = ArbFloat{p}(x)
end

# get and set working precision for ArbFloat

const ArbFloatPrecision = [116,]

precision(x::ArbFloat{P}) where {P} = P
precision(::Type{ArbFloat{P}}) where {P} = P
precision(::Type{ArbFloat}) = ArbFloatPrecision[1]
# allow inquiring the precision of the module: precision(ArbFloats)
precision(::Type{Type{Val{:ArbFloats}}}) = precision(ArbFloat)
precision(m::Module) = precision(Type{Val{Symbol(m)}})

function setprecision(::Type{ArbFloat}, x::Int; augmentby::Int=0)
    x = x + augmentby
    x = max(11, abs(x))
    x > 4095 && warn("ArbFloats are designed to work best at precisions < 4096 bits")
    ArbFloatPrecision[1] = x
    return x
end


# a type specific hash function helps the type to 'just work'
const hash_arbfloat_lo = (UInt === UInt64) ? 0x37e642589da3416a : 0x5d46a6b4
const hash_0_arbfloat_lo = hash(zero(UInt), hash_arbfloat_lo)
# two values of the same precision
#    with identical midpoint significands and identical radus_exponentOf2s hash equal
# they are the same value, one is less accurate yet centered about the other
hash(z::ArbFloat{P}, h::UInt) where {P} =
    hash(z.significand1$z.exponentOf2,
         (h $ hash(z.significand2$(~reinterpret(UInt,P)), hash_arbfloat_lo)
            $ hash_0_arbfloat_lo))


function releaseArbFloat(x::ArbFloat{P}) where {P}
    ccall(@libarb(arb_clear), Void, (Ptr{ArbFloat{P}}, ), Ref{x})
end

function initializer(::Type{ArbFloat{P}}) where {P}
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}}, ), Ref{z})
    finalizer(z, releaseArbFloat)
    return z
end

# empty constructor
@inline function ArbFloat()
     P = precision(ArbFloat)
     return initializer(ArbFloat{P})
end

# typemax,typemin realmax,realmin

typemax(::Type{ArbFloat{P}}) where {P} = ArbFloat{P}("Inf")
typemin(::Type{ArbFloat{P}}) where {P} = ArbFloat{P}("-Inf")
realmax(::Type{ArbFloat{P}}) where {P} = ArbFloat{P}(2)^(P+29)
realmin(::Type{ArbFloat{P}}) where {P} = ArbFloat{P}(2)^(-P-29)


function zero(x::ArbFloat{P}) where {P}
    z = initializer( ArbFloat{P} )
    ccall(@libarb(arb_zero), Void, (Ptr{ArbFloat}, ), Ref{z})
    return z
end
function zero(::Type{T}) where {T <: ArbFloat}
    P = precision(T)
    z = initializer( ArbFloat{ P } )
    ccall(@libarb(arb_zero), Void, (Ptr{ArbFloat}, ), Ref{z})
    return z
end

function one(x::ArbFloat{P}) where {P}
    z = initializer( ArbFloat{P} )
    ccall(@libarb(arb_one), Void, (Ptr{ArbFloat}, ), Ref{z})
    return z
end

function one(::Type{T}) where {T <: ArbFloat}
    P = precision(T)
    z = initializer( ArbFloat{ P } )
    ccall(@libarb(arb_one), Void, (Ptr{ArbFloat}, ), Ref{z})
    return z
end

# parts and aspects
# midpoint, radius, lowerbound, upperbound

@inline function ptr_to_midpoint(x::T) where {T <: ArbFloat} # Ptr{ArfFloat}
    return ccall(@libarb(arb_mid_ptr), Ptr{ArfFloat}, (Ptr{T}, ), Ref{x})
end
@inline function ptr_to_radius(x::T) where {T <: ArbFloat} # Ptr{ArfFloat}
    return ccall(@libarb(arb_rad_ptr), Ptr{ArfFloat}, (Ptr{T}, ), Ref{x})
end

function midpoint(x::ArbFloat{P}) where {P}
    z = initializer( ArbFloat{P} )
    ccall(@libarb(arb_get_mid_arb), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), Ref{z}, Ref{x})
    return z
end

function radius(x::ArbFloat{P}) where {P}
    z = initializer( ArbFloat{P} ) # is 0
    if !isexact(x)
        ccall(@libarb(arb_get_rad_arb), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), Ref{z}, Ref{x})
    end
    return z
end

function diameter(x::T) where {T <: ArbFloat}
    return 2.0*radius(x)
end

function upperbound(x::T) where {T <: ArbFloat}
    P = precision(T)
    a = initializer( ArfFloat{P} )
    z = initializer( ArbFloat{P} )
    ccall(@libarb(arb_get_ubound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), Ref{a}, Ref{x}, P)
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}), Ref{z}, Ref{a})
    return z
end

function lowerbound(x::T) where {T <: ArbFloat}
    P = precision(T)
    a = initializer( ArfFloat{P} )
    z = initializer( ArbFloat{P} )
    ccall(@libarb(arb_get_lbound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), Ref{a}, Ref{x}, P)
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}), Ref{z}, Ref{a})
    return z
end

bounds(x::T) where {T <: ArbFloat} = ( lowerbound(x), upperbound(x) )


"""
isolate_nonnegative_content(x::ArbFloat)
returns x without any content < 0
if x is strictly < 0, returns ArbFloat's NaN
"""
function isolate_nonnegative_content(x::T) where {T <: ArbFloat}
    lo, hi = bounds(x)
    z = if lo > 0
              x
          elseif hi < 0
              T(NaN)
          else
              mid = hi * 0.5
              r = Float32(mid)
              dr = eps(r) * 0.125
              m = Float64(mid)
              while Float64(r) > m
                  r = r - dr
              end
              midpoint_radius(mid, r)
          end
    return z
end

"""
isolate_positive_content(x::ArbFloat)
returns x without any content <= 0
if x is strictly <= 0, returns ArbFloats' NaN
"""
function isolate_positive_content(x::T) where {T <: ArbFloat}
    lo, hi = bounds(x)
    z = if lo > 0
              x
          elseif hi <= 0
              T(NaN)
          else
              mid = hi * 0.5
              r = Float32(mid)
              dr = 0.125 * eps(r)
              m = Float64(mid)
              while Float64(r) >= m
                  r = r - dr
              end
              midpoint_radius(mid, r)
          end
    return z
end

"""
force_nonnegative_content(x::ArbFloat)
returns x without any content < 0
if x is strictly < 0, returns 0
"""
function force_nonnegative_content(x::T) where {T <: ArbFloat}
    lo, hi = bounds(x)
    z = if lo >= 0
              x
          elseif hi < 0
              zero(T)
          else
              isolate_nonnegative_content(x)
          end
    return z
end

"""
force_positive_content(x::ArbFloat)
returns x without any content <= 0
if x is strictly <= 0, returns eps(lowerbound(x))
"""
function force_positive_content(x::T) where {T <: ArbFloat}
    lo, hi = bounds(x)
    z = if lo > 0
              x
          elseif hi < 0
              eps(lo)
          else
              isolate_positive_content(x)
          end
    return z
end

"""
Returns the effective relative error of x measured in bits,
  defined as the difference between the position of the
  top bit in the radius and the top bit in the midpoint, plus one.
  The result is clamped between plus/minus ARF_PREC_EXACT.
"""
function relative_error(x::T) where {T <: ArbFloat}
    re_bits = ccall(@libarb(arb_rel_error_bits), Int, (Ptr{ArbFloat},), Ref{x})
    return re_bits
end

"""
Returns the effective relative accuracy of x measured in bits,
  equal to the negative of the return value from relativeError().
"""
function relative_accuracy(x::T) where {T <: ArbFloat}
    ra_bits = ccall(@libarb(arb_rel_accuracy_bits), Int, (Ptr{T},), Ref{x})
    return ra_bits
end

"""
Returns the number of bits needed to represent the absolute value
  of the mantissa of the midpoint of x, i.e. the minimum precision
  sufficient to represent x exactly.
  Returns 0 if the midpoint of x is a special value.
"""
function midpoint_precision(x::T) where {T <: ArbFloat}
    mp_bits = ccall(@libarb(arb_bits), Int, (Ptr{ArbFloat},), Ref{x})
    return mp_bits
end

"""
Sets y to a trimmed copy of x: rounds x to a number of bits equal
  to the accuracy of x (as indicated by its radius), plus a few
  guard bits. The resulting ball is guaranteed to contain x,
  but is more economical if x has less than full accuracy.
"""
function trimmed(x::T) where {T <: ArbFloat}
    P = precision(T)
    z = initializer( ArbFloat{P} )
    ccall(@libarb(arb_trim), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), Ref{z}, Ref{x})
    return z
end
