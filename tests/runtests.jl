# Test ArbFloats.jl

using Compat
using ArbFloats


if VERSION >= v"0.5.0-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

d = joinpath(Pkg.dir("ArbFloats"),"tests")
test_files = [
                joinpath(d,"TestAsType.jl"),
                joinpath(d,"TestAsNumber.jl"),
                joinpath(d,"TestAsInterval.jl")
              ]

#= prepare to test =#

include(joinpath(d,"test_prep.jl"))

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
