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
    z.rad_exp = source.rad_exp
    z.rad_man = source.rad_man
    z
end

function deepcopyradius{P}(target::ArbFloat{P}, source::ArbFloat{P})
    target.rad_exp = source.rad_exp
    target.rad_man = source.rad_man
    target
end

function copymidpoint{P}(target::ArbFloat{P}, source::ArbFloat{P})
    z = deepcopy(target)
    z.mid_exp = source.mid_exp
    z.mid_size = source.mid_size
    z.mid_d1 = source.mid_d1
    z.mid_d2 = source.mid_d2
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


eps{P}(::Type{ArbFloat{P}}) = ldexp(1.0,-P) # for intertype workings
function eps{P}(x::ArbFloat{P})   # for intratype workings
    r = radius(x)
    if r == 0
       ldexp(1.0,-P)*x
    else
       r
    end
end

"""Similar to eps(x), epsilon(ArbFloat(x)) adjusts for the uncertainty as given by the radius.
   This function is limited to values within the range of Float64.
"""
function epsilon{P}(x::ArbFloat{P})
  if (radius(x) == 0)
     return eps(x)
  end
  midpoint_fr, midpoint_xp = frexp(eps(convert(Float64,midpoint(x))))
  radius_fr, radius_xp = frexp(eps(convert(Float64,radius(x))))
  fr = (midpoint_fr + radius_fr)*0.5
  xp = midpoint_xp + radius_xp
  if isodd(xp)
     fr = fr + 0.25
  end
  xp = xp >> 1
  ldexp(fr,xp)
end
