using BinDeps
using Compat


# ensure the requisite libraries are available

noNemo = "Nemo.jl is not found:\n  Pkg.rm(\"Nemo\"); Pkg.add(\"Nemo\"); quit()\n  Pkg.rm(\"ArbFloats\");Pkg.add(\"ArbFloats\");"
reNemo = "Nemo.jl is not as expected:\n  Pkg.rm(\"Nemo\"); Pkg.add(\"Nemo\"); quit()\n  Pkg.rm(\"ArbFloats\");Pkg.add(\"ArbFloats\");"


function package_directory(pkgName::String)
    pkgdir = Base.find_package(pkgName)
    nothing == pkgdir && throw(ErrorException(noNemo))
    return abspath(joinpath(split(pkgdir, pkgName)[1], pkgName))
end    

function library_filepath(libsdir::String, filenames::Vector{String}, libname::String)
    libfile = filenames[ findfirst([startswith(x,libname) for x in filenames]) ]
    return joinpath( libsdir, libfile )
end

NemoLibsDir = abspath(joinpath( package_directory("Nemo"), "local/lib"))
libFiles = readdir(NemoLibsDir)

libarb   = library_filepath( NemoLibsDir, libFiles, "libarb"  )
libflint = library_filepath( NemoLibsDir, libFiles, "libflint")

isfile(libarb)   || throw(ErrorException(reNemo))
isfile(libflint) || throw(ErrorException(reNemo))
