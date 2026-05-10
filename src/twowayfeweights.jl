module twowayfeweights

    using Random
    using DataFrames
    using RCall
    using Test
    using Statistics
    using OrderedCollections
    using CategoricalArrays
    using LinearAlgebra
    using FixedEffectModels

    # Package code here.

    # Util functions
    include("utils_1_renames.jl")
    include("utils_2_twfe_rename.jl")
    include("twowayfeweights_normalize_var.jl")
    include("utils_3_twfe_transform.jl")
    include("utils_4_twfe_filter.jl")
    include("utils_5_twfe_summarize_weights.jl")
    include("utils_6_test_random_weights.jl")

end
