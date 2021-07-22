using Documenter, ParametricInversion

makedocs(;
    modules=[ParametricInversion],
    format=Documenter.HTML(assets = String[]),
    pages=[
        "Home" => "index.md",
        "relation" => "relation.md",
    ],
    repo="https://github.com/zenna/ParametricInversion.jl/blob/{commit}{path}#L{line}",
    sitename="ParametricInversion.jl",
    authors="Zenna Tavares"
)

deploydocs(;
    repo="github.com/zenna/ParametricInversion.jl",
)
