
zero{T<:ArbFloat}(::Type{T}) = initializer(T)
zero(::Type{ArbFloat}) = initializer(ArbFloat{precision(ArbFloat)})

function one{T<:ArbFloat}(::Type{T})
    z = initializer(T)
    z.exponentOf2 = 1
    z.nwords_sign = 2
    z.significand1 =  one(UInt) + ((-1 % UInt)>>1)
    return z
end
one(::Type{ArbFloat}) = initializer(ArbFloat{precision(ArbFloat)})

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

function copy{P}(x::ArbFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    z
end

function deepcopy{P}(x::ArbFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    z
end

function copyradius{P}(target::ArbFloat{P}, source::ArbFloat{P})
    z = deepcopy(target)
    z.radius_exponentOf2 = source.radius_exponentOf2
    z.radius_significand = source.radius_significand
    z
end

function deepcopyradius{P}(target::ArbFloat{P}, source::ArbFloat{P})
    target.radius_exponentOf2 = source.radius_exponentOf2
    target.radius_significand = source.radius_significand
    target
end

function copymidpoint{P}(target::ArbFloat{P}, source::ArbFloat{P})
    z = deepcopy(target)
    z.exponentOf2  = source.exponentOf2
    z.nwords_sign  = source.nwords_sign
    z.significand1 = source.significand1
    z.significand2 = source.significand2
    z
end

"""
Rounds x to a number of bits equal to the accuracy of x (as indicated by its radius), plus a few guard bits.
The resulting ball is guaranteed to contain x, but is more economical if x has less than full accuracy.
(from arb_trim documentation)
"""
function trim{P}(x::ArbFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_trim), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
    z
end

"""
Rounds x to a clean estimate of x as a point value.
"""
function tidy{P}(x::ArbFloat{P})
    s = smartarbstring(x)
    ArbFloat{P}(s)
end


function decompose{P}(x::ArbFloat{P})
    # decompose x as num * 2^pow / den
    # num, pow, den = decompose(x)
    bfprec=precision(BigFloat)
    setprecision(BigFloat,P)
    bf = convert(BigFloat, x)
    n,p,d = decompose(bf)
    setprecision(BigFloat,bfprec)
    n,p,d
end
