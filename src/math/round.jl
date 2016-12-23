#=
#define FMPR_RND_DOWN  0    RoundingMode{:Down}()
#define FMPR_RND_UP    1
#define FMPR_RND_FLOOR 2
#define FMPR_RND_CEIL  3
#define FMPR_RND_NEAR  4
=#

bits_to_rounded_digits(bits::Int32) = cld((bits * 3010%Int32), 10000%Int32)
bits_to_rounded_digits(bits::Int64) = bits_to_rounded_digits(bits%Int32)
digits_to_rounded_bits(digs::Int32) = fld((digs * 10000%Int32), 3010%Int32) + 1%Int32        
digits_to_rounded_bits(digs::Int64) = digits_to_rounded_bits(digs%Int32)

#=
sigBitsToUse(prec::Int, sig::Int, base::Int) =
    min(prec, ifelse(signbit(sig), -sig, sig) * Float64(nextfloat(Float32(nextfloat(log2(base))))))
=#
sigBitsToUseRadix10(prec::Int, sig::Int) =
    ceil(Int, min(prec, ifelse(signbit(sig), -sig, sig) * 3.3219285)) # log2(10)

sigBitsToUseRadix2(prec::Int, sig::Int) =
    min(prec, ifelse(signbit(sig), -sig, sig) * 1)         # log2(2)

function sigBitsToUse(prec::Int, sig::Int, base::Int)
    if base==2
        return sigBitsToUseRadix2(prec, sig)
    elseif base==10
        return sigBitsToUseRadix10(prec, sig)
    else
        throw(ErrorException(string("Not Implemented for radix ",base)))
    end
end

function round{P}(x::ArbFloat{P}, places::Int=P, base::Int=2)
    ((base==2) | (base==10)) || throw(ErrorException(string("Expecting base in (2,10), radix ",base," is not supported.")))
    places = max(1, abs(places))
    sigbits = base==2 ? places : digits_to_rounded_bits(places)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_round), Void,  (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Int), &z, &x, sigbits)
    return z
end

function ceil{P}(x::ArbFloat{P}, places::Int=P, base::Int=2)
    ((base==2) | (base==10)) || throw(ErrorException(string("Expecting base in (2,10), radix ",base," is not supported.")))
    places = max(1, abs(places))
    sigbits = base==2 ? places : digits_to_rounded_bits(places)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_ceil), Void,  (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Int), &z, &x, sigbits)
    return z
end

function floor{P}(x::ArbFloat{P}, places::Int=P, base::Int=2)
    ((base==2) | (base==10)) || throw(ErrorException(string("Expecting base in (2,10), radix ",base," is not supported.")))
    places = max(1, abs(places))
    sigbits = base==2 ? places : digits_to_rounded_bits(places)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_floor), Void,  (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Int), &z, &x, sigbits)
    return z
end

function trunc{P}(x::ArbFloat{P}, places::Int=P, base::Int=2)
    ((base==2) | (base==10)) || throw(ErrorException(string("Expecting base in (2,10), radix ",base," is not supported.")))
    places = max(1, abs(places))
    sigbits = base==2 ? places : digits_to_rounded_bits(places)
    z = initializer(ArbFloat{P})
    if signbit(x)
        ccall(@libarb(arb_ceil), Void,  (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Int), &z, &x, sigbits)
    else
        ccall(@libarb(arb_floor), Void,  (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Int), &z, &x, sigbits)
    end
    return z
end

function round{I<:Integer,P}(::Type{I}, x::ArbFloat{P}, sig::Int=P, base::Int=2)
    z = round(x, sig, base)
    return convert(I, z)
end
function ceil{I<:Integer,P}(::Type{I}, x::ArbFloat{P}, sig::Int=P, base::Int=2)
    z = ceil(x, sig, base)
    return convert(I, z)
end
function floor{I<:Integer,P}(::Type{I}, x::ArbFloat{P}, sig::Int=P, base::Int=2)
    z = floor(x, sig, base)
    return convert(I, z)
end
function trunc{I<:Integer,P}(::Type{I}, x::ArbFloat{P}, sig::Int=P, base::Int=2)
    z = trunc(x, sig, base)
    return convert(I, z)
end


fld{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, floor(x/y))
cld{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, ceil(x/y))
div{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, trunc(x/y))

rem{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, x - div(x,y)*y)
mod{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, x - fld(x,y)*y)

function divrem{P}(x::ArbFloat{P}, y::ArbFloat{P})
   dv = div(x,y)
   r  = x - d*y
   rm = convert(Int, r)
   return dv,rm
end

function fldmod{P}(x::ArbFloat{P}, y::ArbFloat{P})
   fd = fld(x,y)
   m  = x - d*y
   md = convert(Int, m)
   return fd,md
end
