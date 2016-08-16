module TestAsInterval


afIvl1 = midpoint_radius(ArbFloat(1.0), ArbFloat(1.0e-8))
afIvl2 = midpoint_radius(ArbFloat(1.0), ArbFloat(1.0e-10))
afIvl3 = nextfloat(afIvl2)

@test contains(afIvl1, afIvl2)
@test overlap(afIvl2, afIvl3)

end # module
