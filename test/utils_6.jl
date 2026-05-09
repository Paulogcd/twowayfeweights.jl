@testset "twowayfeweights_test_random_weights.jl" begin
    
    # We first generate randomly the number of group and of time periods.
    G = number_of_group = first(Random.rand(2:10, 1))
    T = number_of_periods = first(Random.rand(3:10, 1))

    # For each group, we are then going to generate randomly 
    # the values and add them to the data frame that we 
    # just initialized:
    random_data_frame_test = DataFrames.DataFrame()        
    for g in 1:G
        
        random_Y_test               = Random.rand(T)
        random_D0                   = Random.rand(T)
        random_D                    = Random.rand(T)
        random_controls             = Random.rand(T)
        treatments                  = Random.rand(0:1, T)
        random_weights              = Random.rand(T)
        W                           = Random.rand(T)

        result = DataFrames.DataFrame(
            Y               = random_Y_test,
            G               = g, 
            T               = 1:T, 
            traitement      = random_D, 
            D0              = random_D0,
            control_1       = random_controls,
            control_2       = random_controls.^2,
            treatments      = treatments,
            random_weights  = random_weights,
            W               = W)
        
        append!(random_data_frame_test, result)
    end

    # Now, we transfer this object to R via RCall:
    RCall.@rput random_data_frame_test
    Test.@test random_data_frame_test == RCall.rcopy(R"random_data_frame_test")

    julia_code_result = twowayfeweights_test_random_weights(
        df = random_data_frame_test,
        random_weights = "random_weights")

    R_code_result = rcopy(R"TwoWayFEWeights:::twowayfeweights_test_random_weights(
        df = random_data_frame_test,
        random_weights = 'random_weights')")

    @test R_code_result == julia_code_result
end;
