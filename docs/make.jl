using Documenter
using twowayfeweights

makedocs(
    sitename = "twowayfeweights",
    format = Documenter.HTML(),
    modules = [twowayfeweights]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
