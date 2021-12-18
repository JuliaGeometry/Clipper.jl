using Documenter
using Clipper

makedocs(
    # See https://github.com/JuliaDocs/Documenter.jl/issues/868
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    strict = true,
    sitename = "Clipper",
    pages = [
        "Home" => "index.md",
        "Reference" => "reference.md",
    ],
)

deploydocs(repo = "github.com/JuliaGeometry/Clipper.jl.git")
