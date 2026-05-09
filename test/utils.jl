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
        
        # Data generation
        random_vector_test = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test") # We check they are the same

        # Operation
        julia_code_result   = fn_ctrl_rename(random_vector_test)
        R_code_result       = rcopy(R"TwoWayFEWeights:::fn_ctrl_rename(random_vector_test)")
        
        # Comparison
        # logic_vector        = (julia_code_result .== R_code_result)
        # @test Base.sum(logic_vector) == 100
        @test R_code_result == julia_code_result 
    end;

    @testset "get_controls_rename.jl" begin 

        random_vector_test = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test")

        julia_code_result   = get_controls_rename(random_vector_test)
        R_code_result       = rcopy(R"TwoWayFEWeights:::get_controls_rename(random_vector_test)")
        
        @test R_code_result == julia_code_result
    end;

    @testset "get_treatments_rename.jl" begin 

        random_vector_test  = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test")

        julia_code_result   = get_treatments_rename(random_vector_test)
        R_code_result       = rcopy(R"TwoWayFEWeights:::get_treatments_rename(random_vector_test)")
        
        @test R_code_result == julia_code_result
    end;

    @testset "fn_treatment_weight_rename.jl" begin

        random_vector_test = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test")

        julia_code_result = fn_treatment_weight_rename(random_vector_test)
        R_code_result = rcopy(R"TwoWayFEWeights:::fn_treatment_weight_rename(random_vector_test)")
        
        @test R_code_result == julia_code_result
    end;

    @testset "fn_random_weight_rename.jl" begin

        random_vector_test = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test")

        julia_code_result = fn_random_weight_rename(random_vector_test)
        R_code_result = rcopy(R"TwoWayFEWeights:::fn_random_weight_rename(random_vector_test)")
    
        @test R_code_result == julia_code_result
    end;

    @testset "get_random_weight_rename.jl" begin

        random_vector_test = [Random.randstring(12) for _ in 1:100]
        @rput random_vector_test
        @test random_vector_test == rcopy(R"random_vector_test")

        julia_code_result = get_random_weight_rename(random_vector_test)
        R_code_result = rcopy(R"TwoWayFEWeights:::get_random_weight_rename(random_vector_test)")
        
        @test R_code_result == julia_code_result
    end;

    @testset "twowayfeweights_rename_var.jl" begin
        
        # Data generation
        G = number_of_group = first(Random.rand(2:10, 1))
        T = number_of_periods = first(Random.rand(3:10, 1))

        # For each group, we are then going to generate randomly 
        # the values and add them to the data frame that we just initialized:
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
    
        @test R_code_result == julia_code_result # Test passed! Yay!
    end;

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

        @test R_code_result == julia_code_result
    end

    @testset "twowayfeweights_filter.jl" begin
        
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
                traitement      = random_D, 
                D0              = random_D0,
                control_1       = random_controls,
                control_2       = random_controls.^2,
                treatments      = treatments,
                random_weights  = random_weights)
            
            append!(random_data_frame_test, result)
        end

        # Now, we transfer this object to R via RCall:
        RCall.@rput random_data_frame_test
        Test.@test random_data_frame_test == RCall.rcopy(R"random_data_frame_test")

        julia_code_result = twowayfeweights_filter(
            df = random_data_frame_test,
            Y = "Y",
            D = "traitement",
            D0 = "D0",
            G = "G",
            T = "T",
            controls      = ["control_1", "control_2"],
            treatments      = "treatments",
            cmd_type = "fdTR")

        R_code_result = rcopy(R"TwoWayFEWeights:::twowayfeweights_filter(
            df = random_data_frame_test,
            Y = 'Y',
            D = 'traitement',
            D0 = 'D0',
            G = 'G',
            T = 'T',
            controls      = c('control_1', 'control_2'),
            treatments      = 'treatments',
            cmd_type = 'fdTR')")

        @test R_code_result == julia_code_result
    end;
    
# end;