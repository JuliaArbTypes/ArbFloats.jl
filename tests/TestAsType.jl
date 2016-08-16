module TestAsType

using Base.Test
using ArbFloats

af0 = zero(ArbFloat)
af1 = one(ArbFloat)
af2 = af1 + af1
afhalf = af1 / 2
afNaN = ArbFloat(NaN)
afInf = ArbFloat(Inf)

@test isnan(afNaN)
@test isinf(afInf)
@test isfinite(af1)
@test !isfinite(afInf)

@test af1 === af1
@test af1 == af1
@test af1 != af2

end # module
