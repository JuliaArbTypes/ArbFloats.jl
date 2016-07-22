
function zero{P}(::Type{ArbFloat{P}})
    return initializer(ArbFloat{P})
end
function zero(::Type{ArbFloat})
    P = precision(ArbFloat)
    return zero(ArbFloat{P})
end

function one{P}(::Type{ArbFloat{P}})
    z = initializer(ArbFloat{P})
    z.exponentOf2 = 1
    z.nwords_sign = 2
    z.significand1 =  one(UInt) + ((-1 % UInt)>>1)
    return z
end
function one(::Type{ArbFloat})
    P = precision(ArbFloat)
    return one(ArbFloat{P})
end

for (op, i) in ((:two,:2), (:three,:3), (:four, :4))
  @eval begin
    function ($op){P}(::Type{ArbFloat{P}})
        z = initializer(ArbFloat{P})
        ccall(@libarb(arb_set_si), Void, (Ptr{ArbFloat}, Int), &z, $i)
        z
    end
    ($op)(::Type{ArbFloat}) = ($op)(ArbFloat{precision(ArbFloat)})
  end
end

function copy{T<:ArbFloat}(x::T)
    z = initializer(T)
    ccall(@libarb(arb_set), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    return z
end

function deepcopy{T<:ArbFloat}(x::T)
    z = initializer(T)
    ccall(@libarb(arb_set), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    return z
end

function copyradius{T<:ArbFloat}(target::T, source::T)
    z = deepcopy(target)
    z.radius_exponentOf2 = source.radius_exponentOf2
    z.radius_significand = source.radius_significand
    return z
end

function copymidpoint{T<:ArbFloat}(target::T, source::T)
    z = deepcopy(target)
    z.exponentOf2  = source.exponentOf2
    z.nwords_sign  = source.nwords_sign
    z.significand1 = source.significand1
    z.significand2 = source.significand2
    return z
end

"""
Rounds x to a number of bits equal to the accuracy of x (as indicated by its radius), plus a few guard bits.
The resulting ball is guaranteed to contain x, but is more economical if x has less than full accuracy.
(from arb_trim documentation)
"""
function trim{T<:ArbFloat}(x::T)
    z = initializer(T)
    ccall(@libarb(arb_trim), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    return z
end

"""
Rounds x to a clean estimate of x as a point value.
"""
function tidy{T<:ArbFloat}(x::T)
    s = smartarbstring(x)
    return (T)(s)
end


function decompose{T<:ArbFloat}(x::T)
    # decompose x as num * 2^pow / den
    # num, pow, den = decompose(x)
    P = precision(T)
    bfprec=precision(BigFloat)
    setprecision(BigFloat,P)
    bf = convert(BigFloat, x)
    n,p,d = decompose(bf)
    setprecision(BigFloat,bfprec)
    return n,p,d
end
