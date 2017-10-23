using Documenter, ArbFloats

makedocs(
    sitename = "ArbFloats.jl",
    modules  = [ArbFloats], 
    format   = Documenter.Formats.HTML,
    clean    = false,
    pages    = Any["Home" => "index.md"],
    doctest  = true,
)

deploydocs(
    target = "build",
    deps   = Deps.pip("pygments", "mkdocs", "python-markdown-math"),
    make   = nothing,
    repo   = "github.com/JuliaArbTypes/ArbFloats.jl.git",
    julia  = "0.5.0-rc3",
    osname = "linux",
)
