@testset "twowayfeweights_normalize_var.jl" begin
        
    # We first generate randomly the number of group and of time periods.
    G = number_of_group = first(Random.rand(2:10, 1))
    T = number_of_periods = first(Random.rand(3:10, 1))

    # For each group, we are then going to generate randomly 
    # the values and add them to the data frame that we 
    # just initialized:
    random_data_frame_test = DataFrames.DataFrame()
    
    for g in 1:G 

    # This test requires at least 2 individuals in each group, 
    # without which the standard deviation is NaN 
    # and prevents the test.
        
        random_Y_test               = Random.rand(T)
        random_D0                   = Random.rand(T)
        random_D                    = Random.rand(T)
        random_controls             = Random.rand(T)
        treatments                  = Random.rand(0:1, T)
        random_weights              = Random.rand(T)

        result = DataFrames.DataFrame(
            Y               = random_Y_test,
            G               = g, 
            T               = 1:T, 
            D               = random_D, 
            D0              = random_D0,
            controls        = random_controls,
            treatments      = treatments,
            random_weights  = random_weights)

        append!(random_data_frame_test, result)

        random_Y_test               = Random.rand(T)
        random_D0                   = Random.rand(T)
        random_D                    = Random.rand(T)
        random_controls             = Random.rand(T)
        treatments                  = Random.rand(0:1, T)
        random_weights              = Random.rand(T)

        result = DataFrames.DataFrame(
            Y               = random_Y_test,
            G               = g, 
            T               = 1:T, 
            D               = random_D, 
            D0              = random_D0,
            controls        = random_controls,
            treatments      = treatments,
            random_weights  = random_weights)

        append!(random_data_frame_test, result)
         
    end

    random_data_frame_test
    varname = "Y"

    # Now, we transfer this object to R via RCall:
    RCall.@rput random_data_frame_test
    Test.@test random_data_frame_test == RCall.rcopy(R"random_data_frame_test")

    julia_code_result = twowayfeweights_normalize_var(
        df = random_data_frame_test,
        varname = "Y")

    R_code_result = rcopy(R"TwoWayFEWeights:::twowayfeweights_normalize_var(
        df = random_data_frame_test,
        varname = 'Y')")
    
    Test.@test julia_code_result[:retcode] == R_code_result[:retcode]
    Test.@test julia_code_result[:df] == R_code_result[:df]
end;