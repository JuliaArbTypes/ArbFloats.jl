for (op, i) in ((:zero,:0), (:one,:1), (:two,:2), (:three,:3), (:four, :4))
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
    z.radiusExp = source.radiusExp
    z.radiusMan = source.radiusMan
    z
end

function deepcopyradius{P}(target::ArbFloat{P}, source::ArbFloat{P})
    target.radiusExp = source.radiusExp
    target.radiusMan = source.radiusMan
    target
end

function copymidpoint{P}(target::ArbFloat{P}, source::ArbFloat{P})
    z = deepcopy(target)
    z.exponent = source.exponent
    z.words_sgn = source.words_sgn
    z.mantissa1 = source.mantissa1
    z.mantissa2 = source.mantissa2
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


"""
   x.midpoint -> (significand, exponent)
                  [0.5,1.0)     2^expo
   x.radius   -> (radial significand, radial exponent)
"""
function frexp{P}(x::ArfFloat{P})
    exponent    = x.exponent
    significand = deepcopy(x)
    significand.exponent = 0
    return significand, exponent
end

function frexp{P}(x::ArbFloat{P})
    significand, exponent = frexp(ArfFloat{P}(x))
    return ArbFloat{P}(significand), ArbFloat{P}(exponent)
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

#=
julia> a=a/60
0.516666666666666379793574294166982543878341733194830405778

julia> setprecision(BigFloat,precision(a));b=convert(BigFloat,a); Float64(eps(b))
1.5930919111324523e-58

julia> ulp2(midpoint(a)),ulp10(midpoint(a))
(1.5930919111324523e-58,1.0e-57)

julia> ldexp(0.5,1-precision(a))
1.5930919111324523e-58

julia> ulp2(midpoint(a)),ulp10(midpoint(a))
(5.0978941156238473e-57,1.0e-55)

julia> setprecision(BigFloat,precision(a));b=convert(BigFloat,a); Float64(eps(b))
5.0978941156238473e-57

julia> ldexp(0.5,6-precision(a))
5.0978941156238473e-57
=#

eps{P}(::Type{ArbFloat{P}}) = ldexp(0.5,1-P) # for intertype workings
function eps{P}(x::ArbFloat{P})   # for intratype workings
    m = midpoint(x)
    ep = if m == zero(ArbFloat{P})
             eps(ArbFloat{P})
         else
             ulp2(midpoint(x))
         end
    return ep
end

"""Similar to eps(x), epsilon(ArbFloat(x)) adjusts for the uncertainty as given by the radius.
   This function is limited to values within the range of Float64.
"""
function epsilon{P}(x::ArbFloat{P})
    r = radius(x)
    ep = if r == zero(ArbFloat{P})
             ulp2(midpoint(x))
         else
             max( ulp2(midpoint(x)), ufp2(r) )
         end
    return ep
end
epsilon(x::Real) = eps(x) # compatible with eps(other types)
