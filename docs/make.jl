using Documenter
using AbrkgaObop

makedocs(
    sitename = "AbrkgaObop",
    format = Documenter.HTML(),
    modules = [AbrkgaObop]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
