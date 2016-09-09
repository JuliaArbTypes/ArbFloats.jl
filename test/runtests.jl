# Test ArbFloats.jl

using Base.Test
using ArbFloats



function package_directory(pkgName::String)
    pkgdir = Base.find_in_path(pkgName)
    nothing == pkgdir && throw(ErrorException(string("Package $pkgName not found.")))
    return abspath(joinpath(split(pkgdir, pkgName)[1], pkgName))
end    

d = joinpath(package_directory("ArbFloats"),"test")
test_files = [
                joinpath(d,"TestAsType.jl"),
                joinpath(d,"TestAsNumber.jl"),
                joinpath(d,"TestAsInterval.jl")
              ]

#= prepare to test =#

# include(joinpath(d,"test_prep.jl"))

#= begin tests =#

# println("Linting ...")
# using Lint
# @test isempty(lintpkg( "MyPackage", returnMsgs=true))
# println("Done.")

#println("Testing ...")
for f in test_files
#    println(f)
    include(f)
end
#println("Done testing.")

# end testing ArbFloats
