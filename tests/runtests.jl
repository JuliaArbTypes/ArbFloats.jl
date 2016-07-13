# Test ArbFloats.jl

using Compat
using Base.Test
using ArbFloats

#= prepare to test =#

include("test_prep.jl")

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

end # Test ArbFloats
