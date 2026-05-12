using Documenter
using TwoWayFEWeights

makedocs(
    sitename = "TwoWayFEWeights",
    format = Documenter.HTML(),
    modules = [TwoWayFEWeights],
    pages = [
        "index.md",
        "TWFE.md",
        "guide.md"
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
