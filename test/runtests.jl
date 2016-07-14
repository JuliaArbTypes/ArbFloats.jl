module TestArbFloats

using ArbFloats
using FactCheck
using Base.Test

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

facts("numbers behave") do
  context("simple value ops") do
    @fact af1 --> af1
    @fact af1<af2 --> true
    @fact af3-af1 --> af2
    @fact af2*af2 --> af4
  end
  context("value recovery") do
    @fact  asin(log(acosh(cosh(exp(sin(afhalf)))))) > afhalf --> true
    @fact  upperbound(asin(log(atanh(tanh(exp(sin(afhalf))))))) >= afhalf --> true
    @fact  lowerbound(asin(log(atanh(tanh(exp(sin(afhalf))))))) <= afhalf --> true
  end
end # numbers behave


#= end tests =#

end # TestArbFloats
