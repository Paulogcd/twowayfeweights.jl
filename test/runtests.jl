using TwoWayFEWeights
using Test
using RCall # We use RCall to compare our output to the one of the original functions.
using Random 
using DataFrames
using Downloads

Test.@testset "TwoWayFEWeights.jl" begin

    # Basic tests
    # include("print.jl")
    include("./0_initialisation.jl");
    include("./0_utils.jl");
    
    # Intermediate function tests
    # include("intermediate_twowayfeweights_calculate.jl");
    include("./1_intermediate_twowayfeweights_normalize_var.jl");
    
    # Final results tests
    include("./2_final_internal_test_wagepan.jl");
    include("./2_final_official_test.jl");

end;