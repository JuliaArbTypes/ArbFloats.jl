using BinDeps
using Compat

@BinDeps.setup

#=
libflint = library_dependency("libflint", aliases=["libflint", "flint"])
libarb = library_dependency("libarb", aliases=["libarb", "arb"])

@BinDeps.install Dict([(:libflint, :libflint), (:libarb, :libarb)])
=#
@BinDeps.install