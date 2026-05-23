"""
    TwowayFEWeights

Julia implementation of two-way fixed effects weight diagnostics.
"""
module TwoWayFEWeights

    using Random
    using DataFrames
    using RCall
    using Test
    using Statistics
    using OrderedCollections
    using CategoricalArrays
    using LinearAlgebra
    using FixedEffectModels
    using StatsBase
    using Missings
    using ShiftedArrays

    # Util functions
    begin
        include("utils_extra.jl")
        export(weighted_mean)
        
        include("utils_1_renames.jl")
        export(fn_ctrl_rename)
        export(get_controls_rename)
        export(fn_treatment_rename)
        export(get_treatments_rename)
        export(fn_treatment_weight_rename)
        export(fn_random_weight_rename)
        export(get_random_weight_rename)
    
        include("utils_2_twfe_rename.jl")
        export(twowayfeweights_rename_var)

        include("twowayfeweights_normalize_var.jl")
        export(twowayfeweights_transform)

        include("utils_3_twfe_transform.jl")
        export(twowayfeweights_filter)

        include("utils_4_twfe_filter.jl")
        export(twowayfeweights_summarize_weights)

        include("utils_5_twfe_summarize_weights.jl")
        export(twowayfeweights_summarize_weights)
        
        include("utils_6_test_random_weights.jl")
        export(twowayfeweights_test_random_weights)
    end

end
