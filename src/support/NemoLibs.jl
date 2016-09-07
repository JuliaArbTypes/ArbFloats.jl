
# ensure the requisite libraries are available

isdir(Pkg.dir("Nemo")) || throw(ErrorException("Nemo not found"))

libDir = Pkg.dir("Nemo/local/lib");
libFiles = readdir(libDir);
libarb   = joinpath(libDir,libFiles[findfirst([startswith(x,"libarb") for x in libFiles])])
libflint = joinpath(libDir,libFiles[findfirst([startswith(x,"libflint") for x in libFiles])])
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
