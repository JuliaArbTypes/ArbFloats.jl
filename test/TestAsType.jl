module TestAsType

using Test
using ArbFloats

af0 = zero(ArbFloat)
af1 = one(ArbFloat)
af2 = af1 + af1
afhalf = af1 / 2
afNaN = ArbFloats.NAN(ArbFloat{precision(ArbFloat)})
afInf = ArbFloats.INF(ArbFloat)

@test isnan(afNaN)
@test isinf(afInf)
@test isfinite(af1)
@test !isfinite(afInf)

@test af1 === af1
@test af1 == af1
@test af1 != af2

@test typeof(ArbFloat{53}(af2)) == ArbFloat{53}
@test typeof(af2) == ArbFloat{precision(ArbFloat)}

@test string(ArbFloat{24}(pi)) == "3.141593"

@test promote(ArbFloat(4), 8//2) == (ArbFloat(4), ArbFloat(4))

end # module
