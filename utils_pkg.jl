using Pkg
Pkg.activate(".")
list_of_pkgs = [
    "Random",
    "DataFrames",
    "Test",
    "Statistics",
    "OrderedCollections",
    "CategoricalArrays",
    "LinearAlgebra",
    "FixedEffectModels",
    "StatsBase",
    "Missings",
    "ShiftedArrays",
    "ReadStatTables",
    "PrettyTables",
    "Crayons",
    "CSV", 
    Downloads
]
for paquet in list_of_pkgs
    Pkg.add(paquet)
end
Pkg.instantiate()