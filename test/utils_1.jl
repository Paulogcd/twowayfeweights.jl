
@testset "utils_1.jl" begin

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

end;