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

        random_data_frame_test = DataFrames.DataFrame([[Random.rand(1) for _ in 1:100] for _ in 1:10], :auto)
        random_data_frame_test = DataFrames.DataFrame(Random.rand(Float64, (10,100)), :auto)
        @rput random_data_frame_test
        @test random_data_frame_test == rcopy(R"random_data_frame_test")

        # random column choice for this data frame: 
        random_choice_controls = Random.rand([1:ncol(random_data_frame_test);], 2)

        julia_code_result = twowayfeweights_rename_var(random_data_frame_test)
        R_code_result = rcopy(R"TwoWayFEWeights:::twowayfeweights_rename_var(random_data_frame_test, controls = colnames())")
        
        logic_vector = (julia_code_result .== R_code_result)
        @test Base.sum(logic_vector) == 100

        @test R_code_result == julia_code_result
    end
    
# end;