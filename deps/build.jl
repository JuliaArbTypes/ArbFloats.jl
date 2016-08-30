using BinDeps, Compat

@BinDeps.setup

const libflint_ver = "2.5.2"
const libarb_ver   = "2.9.0"

flint = library_dependency("libflint")
arb   = library_dependency("libarb")

const libflint_tgz = "http://www.flintlib.org/flint-$libflint_ver.tar.gz"
const libflint_zip = "http://www.flintlib.org/flint-$libflint_ver.zip"
const libarb_git   = "https://github.com/fredrik-johansson/arb.git"
const libarb_zip   = "https://github.com/fredrik-johansson/arb/archive/master.zip"

provides(Sources, URI(libflint_tgz), [flint], os = :Unix)
provides(Sources, URI(libarb_zip), [arb], os = :Unix)
provides(Sources, URI(libflint_zip), [flint], os = :Windows)
provides(Sources, URI(libarb_zip), [arb], os = :Windows)


prefix=joinpath(BinDeps.depsdir(flint),"usr")
srcdir = joinpath(BinDeps.depsdir(flint),"src","flint")

provides(SimpleBuild,
    (@build_steps begin
        GetSources(flint)
        @build_steps begin
            ChangeDirectory(srcdir)
            `./configure --prefix=$prefix`
            `make install`
        end
    end),[flint], os = :Unix)

prefix=joinpath(BinDeps.depsdir(arb),"usr")
srcdir = joinpath(BinDeps.depsdir(arb),"src","arb")

provides(SimpleBuild,
    (@build_steps begin
        GetSources(arb)
        @build_steps begin
            ChangeDirectory(srcdir)
            `./configure --prefix=$prefix`
            `make install`
        end
    end),[arb], os = :Unix)

@BinDeps.install @compat(Dict(:flint => :flint, :arb => :arb))
