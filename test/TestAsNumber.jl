module TestAsNumber

using Test
using ArbFloats

af0 = zero(ArbFloat)
af1 = one(ArbFloat)
af2 = af1 + af1
afhalf = af1 / 2
afNaN = ArbFloat(NaN)
afInf = ArbFloat(Inf)

@test af1 <  af2
@test af1 <= af2
@test af2 >  af1
@test af2 >= af1

@test min(af1,af2) != af2
@test max(af1,af2) == af2

@test  asin(log(acosh(cosh(exp(sin(afhalf)))))) > afhalf
@test  upperbound(asin(log(atanh(tanh(exp(sin(afhalf))))))) >= afhalf
@test  lowerbound(asin(log(atanh(tanh(exp(sin(afhalf))))))) <= afhalf

@test midpoint(afhalf) > midpoint(prevfloat(afhalf))
@test midpoint(afhalf) < midpoint(nextfloat(afhalf))


end # module
