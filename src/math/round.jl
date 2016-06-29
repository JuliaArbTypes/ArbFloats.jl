#=
#define FMPR_RND_DOWN  0    RoundingMode{:Down}()
#define FMPR_RND_UP    1
#define FMPR_RND_FLOOR 2
#define FMPR_RND_CEIL  3
#define FMPR_RND_NEAR  4
=#

function round{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = min(P, ceil(Int, (sig * log(base)/log(2.0))))
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_round), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, sigbits)
    z
end

function ceil{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = min(P, ceil(Int, (sig * log(base)/log(2.0))))
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_ceil), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, sigbits)
    z
end

function floor{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = min(P, ceil(Int, (sig * log(base)/log(2.0))))
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_floor), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, sigbits)
    z
end

function trunc{P}(x::ArbFloat{P}, sig::Int=P, base::Int=10)
    sig=abs(sig); base=abs(base)
    sigbits = min(P, ceil(Int, (sig * log(base)/log(2.0))))
    z = initializer(ArbFloat{P})
    y = abs(x)
    ccall(@libarb(arb_floor), Void,  (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &y, sigbits)
    signbit(x) ? -z : z
end

function round{T,P}(::Type{T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
    z = round(x, sig, base)
    convert(T, z)
end
function ceil{T,P}(::Type{T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
    z = ceil(x, sig, base)
    convert(T, z)
end
function floor{T,P}(::Type{T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
    z = floor(x, sig, base)
    convert(T, z)
end
function trunc{T,P}(::Type{T}, x::ArbFloat{P}, sig::Int=P, base::Int=10)
    z = trunc(x, sig, base)
    convert(T, z)
end

fld{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, floor(x/y))
cld{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, ceil(x/y))
div{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, trunc(x/y))

rem{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, x - div(x,y)*y)
mod{P}(x::ArbFloat{P}, y::ArbFloat{P}) = convert(Int, x - fld(x,y)*y)

function divrem{P}(x::ArbFloat{P}, y::ArbFloat{P})
   d = div(x,y)
   r = convert(Int, x - d*y)
   d,r
end

function fldmod{P}(x::ArbFloat{P}, y::ArbFloat{P})
   d = fld(x,y)
   r = convert(Int, x - d*y)
   d,r
end

