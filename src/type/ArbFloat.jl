
            # P is the precision used with the typed occurance
            # 
type ArbFloat{P}  <: Real     # field and struct names from arb.h 
  mid_exp ::Int               #           fmpz
  mid_size::UInt              #           mp_size_t
  mid_d1  ::Int               #           mantissa_struct
  mid_d2  ::Int               #
  rad_exp ::Int               #           fmpz
  rad_man ::UInt              # 
end

precision{P}(x::ArbFloat{P}) = P
precision{P}(::Type{ArbFloat{P}}) = P
# allow inquiring the precision of the module: precision(ArbFloats)
precision(::Type{Type{Val{:ArbFloats}}}) = precision(ArbFloat)
precision(m::Module) = precision(Type{Val{Symbol(m)}})


# precision is significand precision, significand_bits(FloatNN) + 1, for the hidden bit
typealias ArbFloat16  ArbFloat{ 11}  # read  2 ? 3 or fewer decimal digits to write the same digits ( 16bit Float)
typealias ArbFloat32  ArbFloat{ 24}  # read  6 ? 7 or fewer decimal digits to write the same digits ( 32bit Float)
typealias ArbFloat64  ArbFloat{ 53}  # read 15 ?15 or fewer decimal digits to write the same digits ( 64bit Float)
typealias ArbFloat128 ArbFloat{113}  # read 33 ?34 or fewer decimal digits to write the same digits (128bit Float)
typealias ArbFloat256 ArbFloat{237}  # read 71 ?71 or fewer decimal digits to write the same digits (256bit Float)
typealias ArbFloat512 ArbFloat{496}  # read 148?149 or fewer decimal digits to write the same digits (512bit Float)


# get and set working precision for ArbFloat

const ArbFloatPrecision = [116,]
precision(::Type{ArbFloat}) = ArbFloatPrecision[1]

function setprecision(::Type{ArbFloat}, x::Int)
    priorprecision = precision(ArbFloat)
    x = max(11, abs(x))
    x > 4095 && warn("ArbFloats are designed to work best at precisions < 4096 bits")
    ArbFloatPrecision[1] = x
    priorprecision
end



# a type specific hash function helps the type to 'just work'
const hash_arbfloat_lo = (UInt === UInt64) ? 0x37e642589da3416a : 0x5d46a6b4
const hash_0_arbfloat_lo = hash(zero(UInt), hash_arbfloat_lo)
# two values of the same precision 
#    with identical midpoint significands and identical radial exponents hash equal
# they are the same value, one is less accurate yet centered about the other
hash{P}(z::ArbFloat{P}, h::UInt) = 
    hash(reinterpret(UInt,z.mid_d1)$z.mid_exp, 
         (h $ hash(reinterpret(UInt,z.mid_d2)$(~reinterpret(UInt,P)), hash_arbfloat_lo) 
            $ hash_0_arbfloat_lo))
            
# adapted from Nemo
function (==){P}(x::ArbFloat{P}, y::ArbFloat{P})
    return Bool(ccall(@libarb(arb_eq), Cint, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y))
end
function (!=){P}(x::ArbFloat{P}, y::ArbFloat{P})
    return Bool(ccall(@libarb(arb_ne), Cint, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y))
end

function clearArbFloat{P}(x::ArbFloat{P})
     ccall(@libarb(arb_clear), Void, (Ptr{ArbFloat{P}},), &x)
end

function initializer{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}(0,0,0,0,0,0)
    ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}},), &z)
    finalizer(z, clearArbFloat)
    z
end


function midpoint{P}(x::ArbFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_get_mid_arb), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    z
end

function radius{P}(x::ArbFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_get_rad_arb), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    z
end

function upperbound{P}(x::ArbFloat{P})
    a = ArfFloat{P}(0,0,0,0)
    ccall(@libarb(arf_init), Void, (Ptr{ArfFloat{P}},), &a)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_get_ubound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), &a, &x, P)
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}), &z, &a)
    ccall(@libarb(arf_clear), Void, (Ptr{ArfFloat{P}},), &a)
    z
end

function lowerbound{P}(x::ArbFloat{P})
    a = ArfFloat{P}(0,0,0,0)
    ccall(@libarb(arf_init), Void, (Ptr{ArfFloat{P}},), &a)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_get_lbound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), &a, &x, P)
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}), &z, &a)
    ccall(@libarb(arf_clear), Void, (Ptr{ArfFloat{P}},), &a)
    z
end

bounds{P}(x::ArbFloat{P}) = ( lowerbound(x), upperbound(x) )

function minmax{P}(x::ArbFloat{P}, y::ArbFloat{P})
   x < y ? (x,y) : (y,x)
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
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_trim), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    z
end

