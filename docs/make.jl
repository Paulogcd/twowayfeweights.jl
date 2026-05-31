using Documenter
using DocumenterMermaid
using TwoWayFEWeights

makedocs(
    sitename = "TwoWayFEWeights",
    format = Documenter.HTML(),
    modules = [TwoWayFEWeights],
    pages = [
        "index.md",
        "TWFE.md",
        "guide.md",
        "package_structure.md"
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
