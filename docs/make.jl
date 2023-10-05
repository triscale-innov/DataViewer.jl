using DataViewer
using Documenter

DocMeta.setdocmeta!(DataViewer, :DocTestSetup, :(using DataViewer); recursive=true)

makedocs(;
    modules=[DataViewer],
    authors="TriScale innov <contact@triscale-innov.com>",
    repo="https://github.com/triscale-innov/DataViewer.jl/blob/{commit}{path}#{line}",
    sitename="DataViewer.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://triscale-innov.github.io/DataViewer.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/triscale-innov/DataViewer.jl",
    devbranch="main",
)
