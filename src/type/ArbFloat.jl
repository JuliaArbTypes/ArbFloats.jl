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

# get and set working precision for ArbFloat

const ArbFloatPrecision = [116,]

precision{P}(x::ArbFloat{P}) = P
precision{P}(::Type{ArbFloat{P}}) = P
precision(::Type{ArbFloat}) = ArbFloatPrecision[1]
# allow inquiring the precision of the module: precision(ArbFloats)
precision(::Type{Type{Val{:ArbFloats}}}) = precision(ArbFloat)
precision(m::Module) = precision(Type{Val{Symbol(m)}})

function setprecision(::Type{ArbFloat}, x::Int)
    x = max(11, abs(x))
    x > 4095 && warn("ArbFloats are designed to work best at precisions < 4096 bits")
    ArbFloatPrecision[1] = x
    return x
end

function setprecisionAugmented(::Type{ArbFloat}, x::Int, offset::Int=10)
    return setprecision(ArbFloat, x+offset)
end    


# a type specific hash function helps the type to 'just work'
const hash_arbfloat_lo = (UInt === UInt64) ? 0x37e642589da3416a : 0x5d46a6b4
const hash_0_arbfloat_lo = hash(zero(UInt), hash_arbfloat_lo)
# two values of the same precision
#    with identical midpoint significands and identical radus_exponentOf2s hash equal
# they are the same value, one is less accurate yet centered about the other
hash{P}(z::ArbFloat{P}, h::UInt) =
    hash(z.significand1$z.exponentOf2,
         (h $ hash(z.significand2$(~reinterpret(UInt,P)), hash_arbfloat_lo)
            $ hash_0_arbfloat_lo))

# empty constructor
ArbFloat() = ArbFloat{precision(ArbFloat)}()


# typemax,realmax realmax,realmin

typemax{P}(::Type{ArbFloat{P}}) = ArbFloat{P}("Inf")
typemin{P}(::Type{ArbFloat{P}}) = ArbFloat{P}("-Inf")
realmax{P}(::Type{ArbFloat{P}}) = ArbFloat{P}(2)^(P+29)
realmin{P}(::Type{ArbFloat{P}}) = ArbFloat{P}(2)^(-P-29)



# parts and aspects
# midpoint, radius, lowerbound, upperbound, bounds

@inline function ptr_to_midpoint{T<:ArbFloat}(x::T) # Ptr{ArfFloat}
    return ccall(@libarb(arb_mid_ptr), Ptr{ArfFloat}, (Ptr{T}, ), &x)
end
@inline function ptr_to_radius{T<:ArbFloat}(x::T) # Ptr{ArfFloat}
    return ccall(@libarb(arb_rad_ptr), Ptr{ArfFloat}, (Ptr{T}, ), &x)
end

function midpoint{T<:ArbFloat}(x::T)
    z = T()
    ccall(@libarb(arb_get_mid_arb), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    return z
end

function radius{T<:ArbFloat}(x::T)
    z = T()
    ccall(@libarb(arb_get_rad_arb), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    return z
end

function diameter{T<:ArbFloat}(x::T)
    return 2.0*radius(x)
end

function upperbound{T<:ArbFloat}(x::T)
    P = precision(T)
    a = ArfFloat{P}()
    z = T()
    ccall(@libarb(arb_get_ubound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), &a, &x, P)
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}), &z, &a)
    return z
end

function lowerbound{T<:ArbFloat}(x::T)
    P = precision(T)
    a = ArfFloat{P}()
    z = T()
    ccall(@libarb(arb_get_lbound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), &a, &x, P)
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}), &z, &a)
    return z
end

bounds{T<:ArbFloat}(x::T) = ( lowerbound(x), upperbound(x) )


function max{T<:ArbFloat}(x::T, y::T)
    return (x + y + abs(x - y))/2
end

function min{T<:ArbFloat}(x::T, y::T)
    return (x + y - abs(x - y))/2
end
#=
function min2{T<:ArbFloat}(x::T, y::T)
    return
        if donotoverlap(x,y)
            x < y ? x : y
        else
            xlo, xhi = bounds(x)
            ylo, yhi = bounds(y)
            lo,hi = min(xlo, ylo), min(xhi, yhi)
            md = (hi+lo)/2
            rd = (hi-lo)/2
            midpoint_radius(md, rd)
        end
end

function max2{T<:ArbFloat}(x::T, y::T)
    return
        if donotoverlap(x,y)
            return x > y ? x : y
        else
            xlo, xhi = bounds(x)
            ylo, yhi = bounds(y)
            lo,hi = max(xlo, ylo), max(xhi, yhi)
            md = (hi+lo)/2
            rd = (hi-lo)/2
            return midpoint_radius(md, rd)
        end
end
=#
#=
function max{T<:ArbFloat}(x::T, y::T)
    return ((x>=y) | !(y<x)) ? x : y
end
=#

function minmax{T<:ArbFloat}(x::T, y::T)
   return min(x,y), max(x,y) # ((x<=y) | !(y>x)) ? (x,y) : (y,x)
end

"""
Returns the effective relative error of x measured in bits,
  defined as the difference between the position of the
  top bit in the radius and the top bit in the midpoint, plus one.
  The result is clamped between plus/minus ARF_PREC_EXACT.
"""
function relativeError{T<:ArbFloat}(x::T)
    re_bits = ccall(@libarb(arb_rel_error_bits), Int, (Ptr{T},), &x)
    return re_bits
end

"""
Returns the effective relative accuracy of x measured in bits,
  equal to the negative of the return value from relativeError().
"""
function relativeAccuracy{T<:ArbFloat}(x::T)
    ra_bits = ccall(@libarb(arb_rel_accuracy_bits), Int, (Ptr{T},), &x)
    return ra_bits
end

"""
Returns the number of bits needed to represent the absolute value
  of the mantissa of the midpoint of x, i.e. the minimum precision
  sufficient to represent x exactly.
  Returns 0 if the midpoint of x is a special value.
"""
function midpointPrecision{T<:ArbFloat}(x::T)
    mp_bits = ccall(@libarb(arb_bits), Int, (Ptr{T},), &x)
    return mp_bits
end

"""
Sets y to a trimmed copy of x: rounds x to a number of bits equal
  to the accuracy of x (as indicated by its radius), plus a few
  guard bits. The resulting ball is guaranteed to contain x,
  but is more economical if x has less than full accuracy.
"""
function trimmed{T<:ArbFloat}(x::T)
    z = T()
    ccall(@libarb(arb_trim), Void, (Ptr{T}, Ptr{T}), &z, &x)
    return z
end
