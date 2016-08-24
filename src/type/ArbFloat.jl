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

function midpoint{T<:ArbFloat}(x::T)
    P = precision(T)
    z = ArbFloat{P}()
    z.exponentOf2 = x.exponentOf2
    z.nwords_sign = x.nwords_sign
    z.significand1 = x.significand1
    z.significand2 = x.significand2
    #z.radius_exponentOf2 = zero(Int)
    #z.radius_significand = zero(UInt)
    return z
end

function radius{T<:ArbFloat}(x::T)
    #P = precision(T)
    z = T() #ArbFloat{P}()
    #z.exponentOf2 = x.radius_exponentOf2
    #z.nwords_sign = x.radius_significand
    # z.significand1 = x.significand1
    # z.significand2 = x.significand2
    #z.radius_exponentOf2 = zero(Int)
    #z.radius_significand = zero(UInt)
    #return z
    ccall(@libarb(arb_get_rad_arb), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    return z
end

function upperbound{P}(x::ArbFloat{P})
    a = ArfFloat{P}()
    z = ArbFloat{P}()
    ccall(@libarb(arb_get_ubound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), &a, &x, P)
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}), &z, &a)
    # ccall(@libarb(arf_clear), Void, (Ptr{ArfFloat{P}},), &a)
    z
end

function lowerbound{P}(x::ArbFloat{P})
    a = ArfFloat{P}()
    z = ArbFloat{P}()
    ccall(@libarb(arb_get_lbound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), &a, &x, P)
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}), &z, &a)
    # ccall(@libarb(arf_clear), Void, (Ptr{ArfFloat{P}},), &a)
    z
end

bounds{P}(x::ArbFloat{P}) = ( lowerbound(x), upperbound(x) )

function upperBound{T<:ArbFloat}(x::T, prec::Int)
    P = precision(T)
    a = ArfFloat{P}()
    z = ArbFloat{P}()
    ccall(@libarb(arb_get_ubound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), &a, &x, prec)
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}), &z, &a)
    # ccall(@libarb(arf_clear), Void, (Ptr{ArfFloat{P}},), &a)
    z
end

function lowerBound{T<:ArbFloat}(x::T, prec::Int)
    P = precision(T)
    a = ArfFloat{P}()
    z = ArbFloat{P}()
    ccall(@libarb(arb_get_lbound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), &a, &x, prec)
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}), &z, &a)
    # ccall(@libarb(arf_clear), Void, (Ptr{ArfFloat{P}},), &a)
    z
end

lohiBounds{T<:ArbFloat}(x::T, prec::Int) = ( lowerBound(x, prec), upperBound(x, prec) )


function max{T<:ArbFloat}(x::T, y::T)
    return (x + y + abs(x - y))/2
end

function min{T<:ArbFloat}(x::T, y::T)
    return (x + y - abs(x - y))/2
end

function min2{T<:ArbFloat}(x::T, y::T)
    return
        if donotoverlap(x,y)
            return x < y ? x : y
        else
            xlo, xhi = bounds(x)
            ylo, yhi = bounds(y)
            lo,hi = min(xlo, ylo), min(xhi, yhi)
            md = (hi+lo)/2
            rd = (hi-lo)/2
            return midpoint_radius(md, rd)
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

#=
function max{T<:ArbFloat}(x::T, y::T)
    return ((x>=y) | !(y<x)) ? x : y
end
=#

function minmax{P}(x::ArbFloat{P}, y::ArbFloat{P})
   ((x<=y) | !(y>x)) ? (x,y) : (y,x)
end

function relativeError{P}(x::ArbFloat{P})
    z = P
    ccall(@libarb(arb_rel_error_bits), Void, (Ptr{Int}, Ptr{ArbFloat}), &z, &x)
    z
end

function relativeAccuracy{P}(x::ArbFloat{P})
    z = P
    ccall(@libarb(arb_rel_accuracy_bits), Void, (Ptr{Int}, Ptr{ArbFloat}), &z, &x)
    z
end

function midpointPrecision{P}(x::ArbFloat{P})
    z = P
    ccall(@libarb(arb_bits), Void, (Ptr{Int}, Ptr{ArbFloat}), &z, &x)
    z
end

function trimmedAccuracy{P}(x::ArbFloat{P})
    z = ArbFloat{P}()
    ccall(@libarb(arb_trim), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    z
end





# precision is significand precision, significand_bits(FloatNN) + 1, for the hidden bit
typealias ArbFloat16  ArbFloat{ 11}  # read   2 ? 3 or fewer decimal digits to write the same digits ( 16bit Float)
typealias ArbFloat32  ArbFloat{ 24}  # read   6 ? 7 or fewer decimal digits to write the same digits ( 32bit Float)
typealias ArbFloat64  ArbFloat{ 53}  # read  15 ?15 or fewer decimal digits to write the same digits ( 64bit Float)
typealias ArbFloat128 ArbFloat{113}  # read  33 ?34 or fewer decimal digits to write the same digits (128bit Float)
typealias ArbFloat256 ArbFloat{237}  # read  71 ?71 or fewer decimal digits to write the same digits (256bit Float)
typealias ArbFloat512 ArbFloat{496}  # read 148?149 or fewer decimal digits to write the same digits (512bit Float)
