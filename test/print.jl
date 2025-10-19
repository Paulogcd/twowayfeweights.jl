# This document is dedicated to testing the functions in the print.jl file.
@testset "print.jl" begin
    RCall.reval("1+1")
    # @rlibrary TwoWayFEWeights
    # RCall.reval("install.packages('twowayfeweights')") # I do not manage to install the R package via RCall. 
    # This should looked into. 

    # R"TwoWayFEWeights::"
    # R"ls('package:TwoWayFEWeights')"
    R"ls(getNamespace('TwoWayFEWeights'))" # To get all the functions

end

1+1
using Pkg 
Pkg.activate(".")
using RCall

R"rnorm(10)"
R"install.packages('twowayfeweights')"
R"install.packages('twowayfeweights')"
@rlibrary TwoWayFEWeights