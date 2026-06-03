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

# Util functions
begin
    include("src/utils_extra.jl")
    # export(weighted_mean)
    
    include("src/utils_1_renames.jl")
    # export(fn_ctrl_rename)
    # export(get_controls_rename)
    # export(fn_treatment_rename)
    # export(get_treatments_rename)
    # export(fn_treatment_weight_rename)
    # export(fn_random_weight_rename)
    # export(get_random_weight_rename)

    include("src/utils_2_twfe_rename.jl")
    # export(twowayfeweights_rename_var)

    include("src/twowayfeweights_normalize_var.jl")
    # export(twowayfeweights_transform)

    include("src/utils_3_twfe_transform.jl")
    # export(twowayfeweights_filter)

    include("src/utils_4_twfe_filter.jl")
    # export(twowayfeweights_summarize_weights)

    include("src/utils_5_twfe_summarize_weights.jl")
    # export(twowayfeweights_summarize_weights)
    
    include("src/utils_6_test_random_weights.jl")
    # export(twowayfeweights_test_random_weights)

    include("src/twowayfeweights_calculate.jl")
    # export(twowayfeweights_calculate)

    include("src/twowayfeweights_f.jl")
    include("src/twowayfeweights_result.jl")
    
    include("src/twowayfeweights_struct.jl")
    include("src/utils_print.jl")
    include("src/print.jl")
end

using ReadStatTables

# For this test, we are going to use the official / original 
# code snipped used in the original package.
repo = "chaisemartinPackages/twowayfeweights/main"
file = "wagepan_twfeweights.dta"
url = "https://raw.githubusercontent.com" * "/" * repo * "/" * file
path = download(url)
wagepan = ReadStatTables.readstat(path)
wagepan = DataFrames.DataFrame(wagepan)

using BenchmarkTools

resultat = twowayfeweights(
    data = wagepan,
    Y = "lwage",
    G = "nr",
    T = "year",
    D = "union",
    type = "feTR",
    summary_measures = true,
    test_random_weights = "educ")

data = wagepan
Y = "lwage"
G = "nr"
T = "year"
D = "union"
type = "feTR"
summary_measures = true
test_random_weights = "educ"

D0 = nothing
controls = nothing
weights = nothing
other_treatments = nothing
path = nothing
