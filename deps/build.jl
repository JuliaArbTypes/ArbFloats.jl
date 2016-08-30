using BinDeps
using Compat

@BinDeps.setup

if !ispath(Pkg.dir("ArbFloats", "deps"))
    mkdir(Pkg.dir("ArbFloats", "deps"))
end
if !ispath(Pkg.dir("ArbFloats", "deps", "downloads"))
    mkdir(Pkg.dir("ArbFloats", "deps", "downloads"))
end
if !ispath(Pkg.dir("ArbFloats", "deps", "usr", "lib"))
    mkdir(Pkg.dir("ArbFloats", "deps", "usr", "lib"))
end

# e.g.JULIA_LIBS =  "/usr/local/lib/julia"
const JULIA_LIBS = realpath(joinpath(JULIA_HOME,Base.LIBDIR,"julia"))
const ARBFLOAT_LIBS = realpath(Pkg.dir("ArbFloats","usr","lib"))
searchdir(path,key) = filter(x->contains(x,key), readdir(path))
search_julialibs(key) = searchdir(JULIA_LIBS, string("lib",key))
search_arbfloatlibs(key) = searchdir(ARBFLOAT_LIBS, string("lib",key))


gmp   = library_dependency("libgmp", aliases=search_julialibs("gmp"))
mpfr  = library_dependency("libmpfr", aliases=search_julialibs("mpfr"))
flint = library_dependency("libflint", aliases=["libflint.so", "libflint.dynlib", "libfint.dll"]
arb   = library_dependency("libarb", aliases=["libarb.so","libarb.dynlib","libarb.dll"])



const m4_ver       = "1.4.17"
const libgmp_ver   = "6.1.1"
const libmpfr_ver  = "4.1.4"
const libmpir_ver  = "2.7.2"
const libflint_ver = "2.5.2"
const libarb_ver   = "2.9.0"

const libgmp_lz    = "https://gmplib.org/download/gmp/gmp-$libgmp_ver.tar.lz"
const libflint_tgz = "http://www.flintlib.org/flint-$libflint_ver.tar.gz"
const libflint_zip = "http://www.flintlib.org/flint-$libflint_ver.zip"
const libarb_git   = "https://github.com/fredrik-johansson/arb.git"
const libarb_zip   = "https://github.com/fredrik-johansson/arb/archive/master.zip"
# If MPIR is used instead of GMP, it must be compiled with the --enable-gmpcompat option.
const libmpir_bz2  = "http://www.mpir.org/mpir-$libmpir_ver.tar.bz2"
const libmpir_zip  = "http://www.mpir.org/mpir-$libmpir_ver.zip"

provides(Sources, URI(libgmp_lz), libgmp)
provides(Sources, URI(libflint_tgz), libflint)
provides(Sources, URI(libarb_zip), libarb, unpacked_dir="libarb")

@BinDeps.load_dependencies
end
