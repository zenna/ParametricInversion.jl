using Documenter, Ailuj

makedocs(;
    modules=[Ailuj],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/zenna/Ailuj.jl/blob/{commit}{path}#L{line}",
    sitename="Ailuj.jl",
    authors="Zenna Tavares",
    assets=String[],
)

deploydocs(;
    repo="github.com/zenna/Ailuj.jl",
)
