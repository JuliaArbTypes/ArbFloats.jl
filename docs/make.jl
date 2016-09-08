using Documenter, ArbFloats

makedocs(modules=[ArbFloats], doctest=true)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "python-markdown-math"),
    repo = "github.com/JuliaArbTypes/ArbFloats.jl.git",
    julia  = "0.5.0-rc3",
    osname = "linux")
