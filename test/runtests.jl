using TwoWayFEWeights
using Test
using RCall # We use RCall to compare our output to the one of the original functions.
using Random 
using DataFrames
using ReadStatTables
using Downloads

Test.@testset "twowayfeweights.jl" begin

    # include("print.jl")
    # include("initialisation.jl");
    # include("utils.jl");
    # include("twowayfeweights_calculate.jl")
    include("twowayfeweights_f.jl")
    # include("twowayfeweights_normalize_var.jl")
    # include("twowayfeweights_result.jl")

    # Internal test with example datasets.
    include("internal_tests_1.jl")
    include("internal_tests_2.jl")
    include("internal_tests_3.jl")
    include("internal_tests_4.jl")

end;