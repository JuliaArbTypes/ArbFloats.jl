using Documenter, ArbFloats

makedocs(modules=[Arbfloats], doctest=true)

deploydocs(deps = Deps.pip("mkdocs", "python-markdown-math"),
    repo = "github.com/JuliaArbTypes/ArbFloats.jl.git",
    julia  = "0.5.0-rc3",
    osname = "linux")
