using Twowayfeweights
using Test
using RCall # We use RCall to compare our output to the one of the original functions.
using Random 
using DataFrames

@testset "twowayfeweights.jl" begin
    # Write your tests here.

    # include("print.jl")
    include("initialisation.jl");
    include("utils.jl");
end;
