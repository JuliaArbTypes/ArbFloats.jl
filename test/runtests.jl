# Test ArbFloats.jl

using Test
using ArbFloats



function package_directory(pkgName::String)
    pkgdir = Base.find_package(pkgName)
    nothing == pkgdir && throw(ErrorException(string("Package $pkgName not found.")))
    return abspath(joinpath(split(pkgdir, pkgName)[1], pkgName))
end    

d = joinpath(package_directory("ArbFloats"),"test")
test_files = [
                "TestAsType.jl",
                "TestAsNumber.jl",
                "TestAsInterval.jl"
              ]

#= prepare to test =#

# include(joinpath(d,"prepareToTest.jl"))

#= begin tests =#

# println("Linting ...")
# using Lint
# @test isempty(lintpkg( "MyPackage", returnMsgs=true))
# println("Done.")

#println("Testing ...")
for f in test_files
#    println(f)
   # include(f)
end
#println("Done testing.")

# end testing ArbFloats
