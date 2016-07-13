# Test ArbFloats.jl

using Compat
using Base.Test
using ArbFloats

#= prepare to test =#

typealias AD15  ArbFloat{50}    # 15 digits
typealias AD30  ArbFloat{100}   # 31 digits
typealias AD100 ArbFloat{333}   # 100 digits
typealias AD300 ArbFloat{997}   # 300 digits

af0 = zero(ArbFloat)
af1 = one(ArbFloat)
af2 = two(ArbFloat)
af3 = three(ArbFloat)
af4 = four(ArbFloat)
afhalf = inv(af2)

#= begin tests =#

@testset "numbers behave" begin
  @testset "simple value ops" begin
    @test af1 === af1
    @test af1 == af1
    @test af1 != af2
    @test af1 <  af2
    @test af1 <= af2 
    @test af2 >  af1
    @test af2 >= af1
  end
  @testset "value recovery" begin
    @test  asin(log(acosh(cosh(exp(sin(afhalf)))))) > afhalf
    @test  upperbound(asin(log(atanh(tanh(exp(sin(afhalf))))))) >= afhalf
    @test  lowerbound(asin(log(atanh(tanh(exp(sin(afhalf))))))) <= afhalf
  end
end # numbers behave


#= end tests =#

end # TestArbFloats
