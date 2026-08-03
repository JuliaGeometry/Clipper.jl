using Clipper
using Documenter

DocMeta.setdocmeta!(Clipper, :DocTestSetup, :(using Clipper); recursive=true)

makedocs(
    modules = [Clipper],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "Clipper.jl",
    pages = [
        "Home" => "index.md",
        "Reference" => "reference.md",
    ],
)

deploydocs(repo = "github.com/JuliaGeometry/Clipper.jl.git")
