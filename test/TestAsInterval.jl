module TestAsInterval

using Base.Test
using ArbFloats

afIvl1 = midpoint_radius(ArbFloat(1.0), ArbFloat(1.0e-8))
afIvl2 = midpoint_radius(ArbFloat(1.0), ArbFloat(1.0e-10))
afIvl3 = nextfloat(afIvl2)

@test contains(afIvl1, afIvl2)
@test !contains(afIvl2, afIvl1)
@test overlap(afIvl2, afIvl3)

@test midpoint(afIvl3) > midpoint(afIvl2)
@test radius(afIvl3) == radius(afIvl2)

end # module
