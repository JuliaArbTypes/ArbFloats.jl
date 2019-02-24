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

integral_digits(x::ArbFloat{P}) where {P} = ceiled(Int, log10(1+floored(abs(x))))

function round(x::ArbFloat{P}, places::Int=integral_digits(P), base::Int=10) where {P}
    ((base==2) | (base==10)) || throw(ErrorException(string("Expecting base in (2,10), radix ",base," is not supported.")))
    sigbits = base==2 ? places+digits_to_rounded_bits(integral_digits(x)) : digits_to_rounded_bits(places+integral_digits(x))
    sigbits = max(1, sigbits) # library call chokes on a value of zero
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_round), Cvoid,  (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, sigbits)
    return z
end

function ceiled(::Type{T}, x::ArbFloat{P}) where {P,T}
    y = ceiled(x)
    return convert(T,y)
end    
function ceiled(x::ArbFloat{P}, places::Int=P, base::Int=2) where {P}
    ((base==2) | (base==10)) || throw(ErrorException(string("Expecting base in (2,10), radix ",base," is not supported.")))
    places = max(1,abs(places))
    sigbits = base==2 ? places : digits_to_rounded_bits(places)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_ceil), Cvoid,  (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, sigbits)
    return z
end
function floored(::Type{T}, x::ArbFloat{P}) where {P,T}
    y = floored(x)
    return convert(T,y)
end    
function floored(x::ArbFloat{P}, places::Int=P, base::Int=2) where {P}
    ((base==2) | (base==10)) || throw(ErrorException(string("Expecting base in (2,10), radix ",base," is not supported.")))
    places = max(1,abs(places))
    sigbits = base==2 ? places : digits_to_rounded_bits(places)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_floor), Cvoid,  (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, sigbits)
    return z
end

function ceil(x::ArbFloat{P}, places::Int=P, base::Int=2) where {P}
    ((base==2) | (base==10)) || throw(ErrorException(string("Expecting base in (2,10), radix ",base," is not supported.")))
    sigbits = base==2 ? places+digits_to_rounded_bits(integral_digits(x)) : digits_to_rounded_bits(places+integral_digits(x))
    sigbits = max(1, sigbits) # library call chokes on a value of zero
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_ceil), Cvoid,  (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, sigbits)
    return z
end

function floor(x::ArbFloat{P}, places::Int=P, base::Int=2) where {P}
    ((base==2) | (base==10)) || throw(ErrorException(string("Expecting base in (2,10), radix ",base," is not supported.")))
    sigbits = base==2 ? places+digits_to_rounded_bits(integral_digits(x)) : digits_to_rounded_bits(places+integral_digits(x))
    sigbits = max(1, sigbits) # library call chokes on a value of zero
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_floor), Cvoid,  (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, sigbits)
    return z
end

function trunc(x::ArbFloat{P}, places::Int=P, base::Int=2) where {P}
    ((base==2) | (base==10)) || throw(ErrorException(string("Expecting base in (2,10), radix ",base," is not supported.")))
    sigbits = base==2 ? places+digits_to_rounded_bits(integral_digits(x)) : digits_to_rounded_bits(places+integral_digits(x))
    sigbits = max(1, sigbits) # library call chokes on a value of zero
    z = initializer(ArbFloat{P})
    if signbit(x)
        ccall(@libarb(arb_ceil), Cvoid,  (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, sigbits)
    else
        ccall(@libarb(arb_floor), Cvoid,  (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, sigbits)
    end
    return z
end

function round(::Type{I}, x::ArbFloat{P}, sig::Int=P, base::Int=2) where {I <: Integer,P}
    z = round(x, digits=sig, base=base)
    return convert(I, z)
end
function ceil(::Type{I}, x::ArbFloat{P}, sig::Int=P, base::Int=2) where {I <: Integer,P}
    z = ceil(x, digits=sig, base=base)
    return convert(I, z)
end
function floor(::Type{I}, x::ArbFloat{P}, sig::Int=P, base::Int=2) where {I <: Integer,P}
    z = floor(x, digits=sig, base=base)
    return convert(I, z)
end
function trunc(::Type{I}, x::ArbFloat{P}, sig::Int=P, base::Int=2) where {I <: Integer,P}
    z = trunc(x, digits=sig, base=base)
    return convert(I, z)
end


fld(x::ArbFloat{P}, y::ArbFloat{P}) where {P} = convert(Int, floor(x/y))
cld(x::ArbFloat{P}, y::ArbFloat{P}) where {P} = convert(Int, ceil(x/y))
div(x::ArbFloat{P}, y::ArbFloat{P}) where {P} = convert(Int, trunc(x/y))

rem(x::ArbFloat{P}, y::ArbFloat{P}) where {P} = convert(Int, x - div(x,y)*y)
mod(x::ArbFloat{P}, y::ArbFloat{P}) where {P} = convert(Int, x - fld(x,y)*y)

function divrem(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
   dv = div(x,y)
   r  = x - d*y
   rm = convert(Int, r)
   return dv,rm
end

function fldmod(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
   fd = fld(x,y)
   m  = x - d*y
   md = convert(Int, m)
   return fd,md
end
