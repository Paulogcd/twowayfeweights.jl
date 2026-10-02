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
    using ReadStatTables
    using PrettyTables
    using Crayons
    using CSV
    using Base.Threads

    begin
        # Util functions
        include(joinpath(@__DIR__, "utils_extra.jl"))
        # export(weighted_mean)
        
        include(joinpath(@__DIR__, "utils_1_renames.jl"))
        # export(fn_ctrl_rename)
        # export(get_controls_rename)
        # export(fn_treatment_rename)
        # export(get_treatments_rename)
        # export(fn_treatment_weight_rename)
        # export(fn_random_weight_rename)
        # export(get_random_weight_rename)
    
        include(joinpath(@__DIR__, "utils_2_twfe_rename.jl"));
        # export(twowayfeweights_rename_var)

        include(joinpath(@__DIR__, "twowayfeweights_normalize_var.jl"));
        # export(twowayfeweights_transform)

        include(joinpath(@__DIR__, "utils_3_twfe_transform.jl"));
        # export(twowayfeweights_filter)

        include(joinpath(@__DIR__, "utils_4_twfe_filter.jl"));
        # export(twowayfeweights_summarize_weights)

        include(joinpath(@__DIR__, "utils_5_twfe_summarize_weights.jl"));
        # export(twowayfeweights_summarize_weights)
        
        include(joinpath(@__DIR__, "utils_6_test_random_weights.jl"));
        # export(twowayfeweights_test_random_weights)

        include(joinpath(@__DIR__, "twowayfeweights_calculate.jl"));
        # export(twowayfeweights_calculate)

        # include("twowayfeweights_f.jl")
        include(joinpath(@__DIR__, "twowayfeweights_result.jl"));
        
        include(joinpath(@__DIR__, "twowayfeweights_struct.jl"));
        include(joinpath(@__DIR__, "utils_print.jl"));
        include(joinpath(@__DIR__, "print.jl"));

        include(joinpath(@__DIR__, "twowayfeweights_function.jl"));
        export(twowayfeweights)
    end

end
