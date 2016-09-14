
function zero{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
    return z
end
function zero(::Type{ArbFloat})
    P = precision(ArbFloat)
    return zero(ArbFloat{P})
end

function one{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
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
        z = ArbFloat{P}()
        ccall(@libarb(arb_set_si), Void, (Ptr{ArbFloat}, Int), &z, $i)
        return z
    end
    ($op)(::Type{ArbFloat}) = ($op)(ArbFloat{precision(ArbFloat)})
  end
end

weakcopy{P}(x::ArbFloat{P}) = WeakRef(x)

function copy{T<:ArbFloat}(x::T)
    z = T()
    ccall(@libarb(arb_set), Void, (Ptr{T}, Ptr{T}), &z, &x)
    finalizer(z, release_arb)
    return z
end

function deepcopy{T<:ArbFloat}(x::T)
    z = T()
    ccall(@libarb(arb_set), Void, (Ptr{T}, Ptr{T}), &z, &x)
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

function midpoint_radius{T<:ArbFloat}(x::T)
    return midpoint(x), radius(x)
end

function midpoint_radius{T<:ArbFloat}(midpt::T, radius::T)
    z = midpoint(midpt)
    ccall(@libarb(arb_add_error), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &radius)
    return z
end

function midpoint_radius{T<:ArbFloat}(midpoint::T, radius::Float64)
    rad = convert(T, radius)
    return midpoint_radius(midpoint, rad)
end


"""
Rounds x to a number of bits equal to the accuracy of x (as indicated by its radius), plus a few guard bits.
The resulting ball is guaranteed to contain x, but is more economical if x has less than full accuracy.
(from arb_trim documentation)
"""
function trim{T<:ArbFloat}(x::T)
    z = T()
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
