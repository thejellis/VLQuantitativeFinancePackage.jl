using Documenter, VLQuantitativeFinancePackage

push!(LOAD_PATH,"../src/")

makedocs(
    sitename="VLQuantitativeFinancePackage.jl",
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [VLQuantitativeFinancePackage],
    pages = [
        "Home" => "index.md",
        "Fixed Income" => "fixed.md",
        "Equity" => "equity.md",
        "Derivatives" => "derivatives.md",
    ]
)