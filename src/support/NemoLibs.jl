
# ensure the requisite libraries are available

function package_directory(pkgName::String)
    pkgdir = Base.find_in_path(pkgName)
    nothing == pkgdir && throw(ErrorException("please Pkg.add(\"$pkgName\")"))
    pkgdir = abspath(joinpath( split( pkgdir, pkgName)[1], pkgName))
    return pkgdir
end    

const NemoLibsDir = abspath(joinpath( package_directory("Nemo"), "local/lib"))

libFiles = readdir(NemoLibsDir);
libarb   = joinpath(NemoLibsDir,libFiles[findfirst([startswith(x,"libarb") for x in libFiles])])
libflint = joinpath(NemoLibsDir,libFiles[findfirst([startswith(x,"libflint") for x in libFiles])])

isfile(libarb)   || throw(ErrorException("libarb not found"))
isfile(libflint) || throw(ErrorException("libflint not found"))

# prepare the libraries for use

if is_linux() || is_bsd()
    libarb = String(split(libarb,".so")[1])
    libflint = String(split(libflint,".so")[1])
end
if is_apple()
    libarb = String(split(libarb,".dynlib")[1])
    libflint = String(split(libflint,".dynlib")[1])
end
if is_windows()
    libarb = String(split(libarb,".dll")[1])
    libflint = String(split(libflint,".dll")[1])
end

macro libarb(sym)
    (:($sym), libarb)
end

macro libflint(sym)
    (:($sym), libflint)
end
