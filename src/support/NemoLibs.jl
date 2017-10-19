import Base.Sys: islinux, isbsd, isunix, isapple, iswindows
# ensure the requisite libraries are available

const noNemo = "Nemo.jl is not found:\n  Pkg.rm(\"Nemo\"); Pkg.add(\"Nemo\"); quit()\n  Pkg.rm(\"ArbFloats\");Pkg.add(\"ArbFloats\");"
const reNemo = "Nemo.jl is not as expected:\n  Pkg.rm(\"Nemo\"); Pkg.add(\"Nemo\"); quit()\n  Pkg.rm(\"ArbFloats\");Pkg.add(\"ArbFloats\");"

function package_directory(pkgName::String)
    pkgdir = Base.find_in_path(pkgName)
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

if (islinux() || isbsd() || isunix())
    libarb = String(split(libarb,".so")[1])
    libflint = String(split(libflint,".so")[1])
elseif isapple()
    libarb = String(split(libarb,".dynlib")[1])
    libflint = String(split(libflint,".dynlib")[1])
elseif iswindows()
    libarb = String(split(libarb,".dll")[1])
    libflint = String(split(libflint,".dll")[1])
else
    throw(ErrorException("Unrecognized Operating System"))
end

macro libarb(sym)
    (:($sym), libarb)
end

macro libflint(sym)
    (:($sym), libflint)
end
