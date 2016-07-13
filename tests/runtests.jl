# Test ArbFloats.jl

using Compat
using ArbFloats


if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

test_files = [
              "test_onetwo.jl",
              ]

#= prepare to test =#

include("test_prep.jl")

#= begin tests =#

# println("Linting ...")
# using Lint
# @test isempty(lintpkg( "MyPackage", returnMsgs=true))
# println("Done.")

println("Testing ...")
for f in test_files
    println(f)
    include(f)
end
println("Done testing.")

#= end tests =#


end # Test ArbFloats
