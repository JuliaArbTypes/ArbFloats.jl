
for (op, i) in ((:two,:2), (:three,:3), (:four, :4))
  @eval begin
    function ($op){P}(::Type{ArbFloat{P}})
        z = initializer(ArbFloat{P})
        ccall(@libarb(arb_set_si), Void, (Ptr{ArbFloat}, Int), &z, $i)
        return z
    end
    ($op)(::Type{ArbFloat}) = ($op)(ArbFloat{precision(ArbFloat)})
  end
end

weakcopy{P}(x::ArbFloat{P}) = WeakRef(x)

for fn in (:copy, :deepcopy)
  @eval begin
    function ($fn){P}(x::ArbFloat{P})
        z = initializer(ArbFloat{P})
        ccall(@libarb(arb_set), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
        return z
    end
  end
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

function midpoint_radius{T<:ArbFloat}(x::T)
    return midpoint(x), radius(x)
end

function midpoint_radius{T<:ArbFloat}(midpt::T, radius::T)
    z = midpoint(midpt)
    ccall(@libarb(arb_add_error), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &radius)
    return z
end


function bounds{T<:ArbFloat}(lower::T, upper::T)
    lowerlo, lowerhi = bounds(lower)
    upperlo, upperhi = bounds(upper)
    lo = lowerlo <= upperlo ? lowerlo : upperlo
    hi = lowerhi >= upperhi ? lowerhi : upperhi
    # rad = (hi - lo) * 0.5
    mid = hi*0.5 + lo*0.5
    rad = hi - mid
    r = Float32(rad)
    dr = 0.5 * eps(r)
    z = midpoint_radius(mid, r)
    tstlo, tsthi = bounds(z)
    while (tstlo > lo) || (tsthi < hi)
        z = midpoint_radius(mid, r+dr)
        tstlo, tsthi = bounds(z)
    end
    return z
end

"""
Rounds x to a number of bits equal to the accuracy of x (as indicated by its radius), plus a few guard bits.
The resulting ball is guaranteed to contain x, but is more economical if x has less than full accuracy.
(from arb_trim documentation)
"""
function trim{P}(x::ArbFloat{P})
    z = initializer(ArbFloat{P})
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



function modf{P}(x::ArbFloat{P})
    isneg = signbit(x)
    y = abs(x)
    ipart = trunc(y)
    fpart = y - ipart
    if isneg
        ipart = -ipart
        fpart = -fpart
    end
    return (fpart, ipart)
end

function fmod{P}(fpart::ArbFloat{P}, ipart::ArbFloat{P})
    return ipart + fpart
end  


integerpart{P}(x::ArbFloat{P}) = trunc(x)
fractionalpart{P}(x::ArbFloat{P}) = x - trunc(x)
decimalpart{P}(x::ArbFloat{P}) = smartvalue(fractionalpart(x))

function smartmodf{P}(x::ArbFloat{P})
    isneg = signbit(x)
    y = abs(x)
    ipart = trunc(y)
    fpart = smartvalue(y - ipart)
    if isneg
        ipart = -ipart
        fpart = -fpart
    end
    return (fpart, ipart)
end
