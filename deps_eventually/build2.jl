using BinDeps
using Compat

@BinDeps.setup


# e.g.JULIA_LIBS =  "/usr/local/lib/julia"
const JULIA_LIBS = realpath(joinpath(JULIA_HOME,Base.LIBDIR,"julia"))
searchdir(path,key) = filter(x->contains(x,key), readdir(path))
searchlibs(key) = searchdir(JULIA_LIBS, string("lib",key))


gmp   = library_dependency("libgmp", aliases=searchlibs("gmp"))
mpfr  = library_dependency("libmpfr", aliases=searchlibs("mpfr"))
flint = library_dependency("libflint", aliases
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
# If MPIR is used instead of GMP, it must be compiled with the --enable-gmpcompat option.
const libmpir_bz2  = "http://www.mpir.org/mpir-$libmpir_ver.tar.bz2"
const libmpir_zip  = "http://www.mpir.org/mpir-$libmpir_ver.zip"

const LOCAL_OS =
          if is_linux()
             :Linux
          elseif is_apple()
             :Apple
          elseif is_windows()
             :Windows
          elseif is_bsd()
             :BSD
          else
             throw(ErrorException("The local operating system could not be determined."))
          end;


const m4_file = "m4-$m4_ver"
const m4_tz   = string(m4_file, ".tar.bz2")
const m4_uri  = string("http://ftp.gnu.org/gnu/m4/", m4_tz)




oldwdir = pwd()

pkgdir = Pkg.dir("ArbFloats")
wdir = Pkg.dir("ArbFloats", "deps")
vdir = Pkg.dir("ArbFloats", "local")

if !ispath(Pkg.dir("ArbFloats", "local"))
    mkdir(Pkg.dir("ArbFloats", "local"))
end
if !ispath(Pkg.dir("ArbFloats", "local", "lib"))
    mkdir(Pkg.dir("ArbFloats", "local", "lib"))
end

LDFLAGS = "-Wl,-rpath,$vdir/lib -Wl,-rpath,\$\$ORIGIN/../share/julia/site/v$(VERSION.major).$(VERSION.minor)/ArbFloats/local/lib"
DLCFLAGS = "-fPIC -fno-common"

cd(wdir)

function download_dll(url_string, location_string)
   try
      run(`curl -o $(location_string) -L $(url_string)`)
   catch
      download(url_string, location_string)
   end
end

#install libpthreads

if LOCAL_OS == :Windows
   if Int == Int32
      download_dll("http://nemocas.org/binaries/w32-libwinpthread-1.dll", joinpath(vdir, "lib", "libwinpthread-1.dll"))
   else
      download_dll("http://nemocas.org/binaries/w64-libwinpthread-1.dll", joinpath(vdir, "lib", "libwinpthread-1.dll"))
   end
end

cd(wdir)

# install M4

if LOCAL_OS != :Windows
   try
      run(`m4 --version`)
   catch
      download(m4_uri, joinpath(wdir, m4_tbz2))
      run(`tar -xvf $m4_tz`)
      run(`rm $m4_tz`)
      cd("$wdir/$m4_file")
      run(`./configure --prefix=$vdir`)
      run(`make`)
      run(`make install`)
   end
end

cd(wdir)


# install MPFR

if !ispath(Pkg.dir("Nemo", "local", mpfr_file"mpfr-3.1.4"))
   download("http://ftp.gnu.org/gnu/mpfr/mpfr-3.1.4.tar.bz2", joinpath(wdir, "mpfr-3.1.4.tar.bz2"))
end

if LOCAL_OS == :Windows
   if Int == Int32
      download_dll("http://nemocas.org/binaries/w32-libmpfr-4.dll", joinpath(vdir, "lib", "libmpfr-4.dll"))
   else
      download_dll("http://nemocas.org/binaries/w64-libmpfr-4.dll", joinpath(vdir, "lib", "libmpfr-4.dll"))
   end
else
   run(`tar -xvf mpfr-$mpfr_ver.tar.bz2`)
   run(`rm mpfr-$mpfr_ver.tar.bz2`)
   cd("$wdir/mpfr-$mpfr_ver")
   withenv("LD_LIBRARY_PATH"=>"$vdir/lib", "LDFLAGS"=>LDFLAGS) do
      run(`./configure --prefix=$vdir --with-gmp=$vdir --disable-static --enable-shared`)
      run(`make -j8`)
      run(`make install`)
   end
   cd(wdir)
end

cd(wdir)

# install FLINT
try
  run(`git clone https://github.com/wbhart/flint2.git`)
catch
  cd("$wdir/flint2")
  run(`git pull`)
end

if LOCAL_OS == :Windows
   if Int == Int32
      download_dll("http://ArbFloatscas.org/binaries/w32-libflint.dll", joinpath(vdir, "lib", "libflint.dll"))
   else
      download_dll("http://ArbFloatscas.org/binaries/w64-libflint.dll", joinpath(vdir, "lib", "libflint.dll"))
   end
   try
      run(`ln -sf $vdir\\lib\\libflint.dll $vdir\\lib\\libflint-13.dll`)
   end
else
   cd("$wdir/flint2")
   withenv("LD_LIBRARY_PATH"=>"$vdir/lib", "LDFLAGS"=>LDFLAGS) do
      # run(`./configure --prefix=$vdir --extensions="$wdir/antic" --disable-static --enable-shared --with-mpir=$vdir --with-mpfr=$vdir`)
      run(`./configure --prefix=$vdir --disable-static --enable-shared --with-mpfr=$vdir`)
      run(`make -j8`)
      run(`make install`)
   end
end

cd(wdir)

# INSTALL ARB

try
  run(`git clone https://github.com/fredrik-johansson/arb.git`)
catch
  cd("$wdir/arb")
  run(`git pull`)
  cd(wdir)
end

if LOCAL_OS == :Windows
   if Int == Int32
      download_dll("http://ArbFloatscas.org/binaries/w32-libarb.dll", joinpath(vdir, "lib", "libarb.dll"))
   else
      download_dll("http://ArbFloatscas.org/binaries/w64-libarb.dll", joinpath(vdir, "lib", "libarb.dll"))
   end
else
   cd("$wdir/arb")
   withenv("LD_LIBRARY_PATH"=>"$vdir/lib", "LDFLAGS"=>LDFLAGS) do
      run(`./configure --prefix=$vdir --disable-static --enable-shared --with-mpir=$vdir --with-mpfr=$vdir --with-flint=$vdir`)
      run(`make -j8`)
      run(`make install`)
   end
end

cd(wdir)

push!(Libdl.DL_LOAD_PATH, Pkg.dir("ArbFloats", "local", "lib"))

cd(oldwdir)
