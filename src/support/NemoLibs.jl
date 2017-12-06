
# ensure the requisite libraries are available

const noNemo = "Nemo.jl is not found:\n  Pkg.rm(\"Nemo\"); Pkg.add(\"Nemo\"); quit()\n  Pkg.rm(\"ArbFloats\");Pkg.add(\"ArbFloats\");"
const reNemo = "Nemo.jl is not as expected:\n  Pkg.rm(\"Nemo\"); Pkg.add(\"Nemo\"); quit()\n  Pkg.rm(\"ArbFloats\");Pkg.add(\"ArbFloats\");"

if VERSION<=v"0.6.9"
  find_package(pgkName) = Base.find_in_path(pkgName)
end


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

# prepare the libraries for use

@static if (Sys.islinux() || Sys.isbsd())
    libarb = String(split(libarb,".so")[1])
    libflint = String(split(libflint,".so")[1])
end
@static if Sys.isapple()
    libarb = String(split(libarb,".dynlib")[1])
    libflint = String(split(libflint,".dynlib")[1])
end
@static if Sys.iswindows()
    libarb = String(split(libarb,".dll")[1])
    libflint = String(split(libflint,".dll")[1])
end

macro libarb(sym)
    (:($sym), libarb)
end

macro libflint(sym)
    (:($sym), libflint)
end
