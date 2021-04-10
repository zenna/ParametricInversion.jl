using Documenter, ParametricInversion

makedocs(;
    modules=[ParametricInversion],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Intro" => "intro.md",
    ],
    repo="https://github.com/zenna/ParametricInversion.jl/blob/{commit}{path}#L{line}",
    sitename="ParametricInversion.jl",
    authors="Zenna Tavares",
    assets=String[],
)

deploydocs(;
    repo="github.com/zenna/ParametricInversion.jl",
)
