
for (op, i) in ((:two,:2), (:three,:3), (:four, :4))
  @eval begin
    function ($op)(::Type{ArbFloat{P}}) where {P}
        z = initializer(ArbFloat{P})
        ccall(@libarb(arb_set_si), Cvoid, (Ref{ArbFloat{P}}, Int), z, $i)
        return z
    end
    ($op)(::Type{ArbFloat}) = ($op)(ArbFloat{precision(ArbFloat)})
  end
end

weakcopy(x::ArbFloat{P}) where {P} = WeakRef(x)

for fn in (:copy, :deepcopy)
  @eval begin
    function ($fn)(x::ArbFloat{P}) where {P}
        z = initializer(ArbFloat{P})
        ccall(@libarb(arb_set), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), z, x)
        return z
    end
  end
end

function copyradius(target::T, source::T) where {T <: ArbFloat}
    z = deepcopy(target)
    z.radius_exponentOf2 = source.radius_exponentOf2
    z.radius_significand = source.radius_significand
    return z
end

function copymidpoint(target::T, source::T) where {T <: ArbFloat}
    z = deepcopy(target)
    z.exponentOf2  = source.exponentOf2
    z.nwords_sign  = source.nwords_sign
    z.significand1 = source.significand1
    z.significand2 = source.significand2
    return z
end


function bounds(lower::T, upper::T) where {T <: ArbFloat}
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
function trim(x::ArbFloat{P}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_trim), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), z, x)
    return z
end

"""
Rounds x to a clean estimate of x as a point value.
"""
function tidy(x::T) where {T <: ArbFloat}
    s = smartarbstring(x)
    return (T)(s)
end


function decompose(x::T) where {T <: ArbFloat}
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



function modf(x::ArbFloat{P}) where {P}
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

function fmod(fpart::ArbFloat{P}, ipart::ArbFloat{P}) where {P}
    return ipart + fpart
end  


integerpart(x::ArbFloat{P}) where {P} = trunc(x)
fractionalpart(x::ArbFloat{P}) where {P} = x - trunc(x)
decimalpart(x::ArbFloat{P}) where {P} = smartvalue(fractionalpart(x))

function smartmodf(x::ArbFloat{P}) where {P}
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
