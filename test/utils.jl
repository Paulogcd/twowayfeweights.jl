# @testset "utils.jl" begin
    
    # The utils.jl file has 11 different functions:
    # * fn_ctrl_rename
    # * get_controls_rename
    # * fn_treatment_rename
    # * get_treatments_rename
    # * fn_treatment_weight_rename
    # * fn_random_weight_rename
    # * get_random_weight_rename
    # * twowayfeweights_rename_var
    # * twowayfeweights_transform
    # * twowayfeweights_filter
    # * twowayfeweights_summarize_weights
    # * twowayfeweights_test_random_weights

    # To get all the functions from the original package.
    # R"ls(getNamespace('TwoWayFEWeights'))"

    @testset "fn_ctrl_rename.jl" begin 
        
        # We generate a random vector: 
        # R"random_vector_test <- round(runif(100), digits = 2)"
        random_vector_test = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        # @rget random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test") # We check they are the same.

        # We apply our julia code and the original code to this vector: 
        julia_code_result = fn_ctrl_rename(random_vector_test)
        R_code_result = rcopy(R"TwoWayFEWeights:::fn_ctrl_rename(random_vector_test)")
        
        # We compare the output, to check if they are the same:
        logic_vector = (julia_code_result .== R_code_result)
        @test Base.sum(logic_vector) == 100
        # julia_code_result[logic_vector .== 0]
        # R_code_result[logic_vector .== 0]

        @test R_code_result == julia_code_result
        
        # For this precise function, Julia and R do not have the same precision. 
        # Consequently, for each row, the elements of the vectors are slightly off, 
        # by at least one digit. 
        # This is why we introduce "digits = 2" in the definition 
        # of the vector in R.
        # However, the problem seems to persist when we handle numerical values. 
        # Indeed, the extreme values 0.00 and 1.00 will be displayed, and 
        # saved as "1.0" and "0.0", which changes from R to Julia. 
        # This is why I am here using the randstring function from the Random 
        # Julia package.
    
    end

    @testset "get_controls_rename.jl" begin 

        random_vector_test = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test")

        julia_code_result = get_controls_rename(random_vector_test)
        R_code_result = rcopy(R"TwoWayFEWeights:::get_controls_rename(random_vector_test)")
        
        logic_vector = (julia_code_result .== R_code_result)
        @test Base.sum(logic_vector) == 100

        @test R_code_result == julia_code_result
    end

    @testset "get_treatments_rename.jl" begin 

        random_vector_test = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test")

        julia_code_result = get_treatments_rename(random_vector_test)
        R_code_result = rcopy(R"TwoWayFEWeights:::get_treatments_rename(random_vector_test)")
        
        logic_vector = (julia_code_result .== R_code_result)
        @test Base.sum(logic_vector) == 100

        @test R_code_result == julia_code_result
    end

    @testset "fn_treatment_weight_rename.jl" begin

        random_vector_test = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test")

        julia_code_result = fn_treatment_weight_rename(random_vector_test)
        R_code_result = rcopy(R"TwoWayFEWeights:::fn_treatment_weight_rename(random_vector_test)")
        
        logic_vector = (julia_code_result .== R_code_result)
        @test Base.sum(logic_vector) == 100

        @test R_code_result == julia_code_result
    end

    @testset "fn_random_weight_rename.jl" begin

        random_vector_test = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test")

        julia_code_result = fn_random_weight_rename(random_vector_test)
        R_code_result = rcopy(R"TwoWayFEWeights:::fn_random_weight_rename(random_vector_test)")
        
        logic_vector = (julia_code_result .== R_code_result)
        @test Base.sum(logic_vector) == 100

        @test R_code_result == julia_code_result
    end

    @testset "get_random_weight_rename.jl" begin

        random_vector_test = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test")

        julia_code_result = get_random_weight_rename(random_vector_test)
        R_code_result = rcopy(R"TwoWayFEWeights:::get_random_weight_rename(random_vector_test)")
        
        logic_vector = (julia_code_result .== R_code_result)
        @test Base.sum(logic_vector) == 100

        @test R_code_result == julia_code_result
    end

    @testset "twowayfeweights_rename_var.jl" begin
        
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

        # Now, we transfer this object to R via RCall:
        RCall.@rput random_data_frame_test
        Test.@test random_data_frame_test == RCall.rcopy(R"random_data_frame_test")

        julia_code_result = twowayfeweights_rename_var(
            df = random_data_frame_test,
            Y = "Y", 
            G = "G", 
            T = "T", 
            D = "D", 
            D0 = "D0",
            controls = "controls",
            treatments = "treatments", 
            random_weights = "random_weights")

        R_code_result = rcopy(R"TwoWayFEWeights:::twowayfeweights_rename_var(
            df = random_data_frame_test,
            Y = 'Y', 
            G = 'G', 
            T = 'T', 
            D = 'D', 
            D0 = 'D0',
            controls = 'controls',
            treatments = 'treatments', 
            random_weights = 'random_weights')")
    
        # Finally, we compare the two results:
        logic_vector = (julia_code_result .== R_code_result)
        @test Base.sum.(eachcol(logic_vector)) == repeat([G * T],8)

        @test R_code_result == julia_code_result # Test passed! Yay!
    end

    @testset "twowayfeweights_transform.jl" begin
        
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

        # Now, we transfer this object to R via RCall:
        RCall.@rput random_data_frame_test
        Test.@test random_data_frame_test == RCall.rcopy(R"random_data_frame_test")

        julia_code_result = twowayfeweights_transform(
            df = random_data_frame_test,
            controls        = ["controls"],
            weights         = ["random_weights"],
            treatments      = ["treatments"])

        R_code_result = rcopy(R"TwoWayFEWeights:::twowayfeweights_transform(
            df = random_data_frame_test,
            controls = 'controls',
            treatments = 'treatments', 
            weights = 'random_weights')")

        R_code_result.Tfactor == 
            julia_code_result.Tfactor

        DataFrames.names(julia_code_result)
        DataFrames.names(R_code_result)

        setdiff(DataFrames.names(R_code_result),
            (DataFrames.names(julia_code_result)))
    
        # Finally, we compare the two results:
        logic_vector = (julia_code_result .== R_code_result)
        @test Base.sum.(eachcol(logic_vector)) == repeat([G * T],11)

        @test R_code_result == julia_code_result
    end
    
# end;