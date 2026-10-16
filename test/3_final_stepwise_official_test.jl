Test.@testset "Stepwise official test" begin
    include("./3_2_stepwise_test_1.jl"); # Everything passes

    include("./3_2_stepwise_test_2.jl"); # Everything passes

    include("./3_2_stepwise_test_3.jl"); # Everything passes on GitHub
    # Locally, we have 2 errors at Step 5: results - 
    # nr_weights (R: 9876 vs Julia: 9877)
    # nr_plus (R: 5371 vs Julia: 5372)

    include("./3_2_stepwise_test_4.jl"); # 1 test fails at step 5 - result: 
    # Stacktrace:
    # [1] top-level scope
    # @ ~/twowayfeweights.jl/test/3_2_stepwise_test_4.jl:72
    # ┌ Warning: RCall.jl: Warning in as.numeric(data_R$data[[v]]) : NAs introduced by coercion
    # └ @ RCall ~/.julia/packages/RCall/uXeD3/src/io.jl:166
    # ┌ Warning: RCall.jl: The variables 'ctrl_styr_12', 'ctrl_styr_27', 'ctrl_styr_58', 'ctrl_styr_73',
    # │ 'ctrl_styr_115', 'ctrl_styr_119' and 105 others have been removed because of
    # │ collinearity (see $collin.var).
    # └ @ RCall ~/.julia/packages/RCall/uXeD3/src/io.jl:166
    # ┌ Warning: RCall.jl: Warning in sqrt(sum(dat$nat_weight * (dat$W - W_mean)^2, na.rm = TRUE)) :
    # │   NaNs produced
    # │ Warning in sqrt(T_k + S_k^2/(1 - P_k)) : NaNs produced
    # └ @ RCall ~/.julia/packages/RCall/uXeD3/src/io.jl:166
    # k = "nr_plus"
    # eltype(julia_object_k) = Int64
    # eltype(R_object_k) = Int64
    # length(julia_object_k) = 1
    # length(R_object_k) = 1
    # maximum(abs.(julia_object_k .- R_object_k)) = 3
    # R_object_k = 4532
    # julia_object_k = 4535

    # Step 5: results: Test Failed at /Users/paulogcd/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:323
    # Expression: result_approx
    # Stacktrace:
    # [1] macro expansion
    #     @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:758 [inlined]
    # [2] compare_R_julia(R_object::OrderedDict{Symbol, Any}, julia_object::OrderedDict{Symbol, Any})
    #     @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:323
    # [3] macro expansion
    #     @ ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:251 [inlined]
    # [4] macro expansion
    #     @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:1967 [inlined]
    # [5] test_step_5_result(data_R::OrderedDict{Symbol, Any}, data_julia::Dict{Symbol, Any}, save::Bool)
    #     @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:225
    # k = "nr_minus"
    # eltype(julia_object_k) = Int64
    # eltype(R_object_k) = Int64
    # length(julia_object_k) = 1
    # length(R_object_k) = 1
    # maximum(abs.(julia_object_k .- R_object_k)) = 4
    # R_object_k = 24
    # julia_object_k = 28

    # Step 5: results: Test Failed at /Users/paulogcd/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:323
    # Expression: result_approx
    # Stacktrace:
    # [1] macro expansion
    #     @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:758 [inlined]
    # [2] compare_R_julia(R_object::OrderedDict{Symbol, Any}, julia_object::OrderedDict{Symbol, Any})
    #     @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:323
    # [3] macro expansion
    #     @ ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:251 [inlined]
    # [4] macro expansion
    #     @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:1967 [inlined]
    # [5] test_step_5_result(data_R::OrderedDict{Symbol, Any}, data_julia::Dict{Symbol, Any}, save::Bool)
    #     @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:225
    # k = "nr_weights"
    # eltype(julia_object_k) = Int64
    # eltype(R_object_k) = Int64
    # length(julia_object_k) = 1
    # length(R_object_k) = 1
    # maximum(abs.(julia_object_k .- R_object_k)) = 7
    # R_object_k = 4556
    # julia_object_k = 4563

    # Step 5: results: Test Failed at /Users/paulogcd/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:323
    # Expression: result_approx
    # Stacktrace:
    # [1] macro expansion
    #     @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:758 [inlined]
    # [2] compare_R_julia(R_object::OrderedDict{Symbol, Any}, julia_object::OrderedDict{Symbol, Any})
    #     @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:323
    # [3] macro expansion
    #     @ ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:251 [inlined]
    # [4] macro expansion
    #     @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:1967 [inlined]
    # [5] test_step_5_result(data_R::OrderedDict{Symbol, Any}, data_julia::Dict{Symbol, Any}, save::Bool)
    #     @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:225
    # Test Summary:            | Pass  Fail  Total     Time
    # Stepwise official test 4 | 3500     3   3503  8m48.4s
    # Step 1: renaming       | 1407         1407     2.8s
    # Step 2: transforming   |  692          692  7m50.4s
    # Step 3: filtering      |  691          691     2.4s
    # Step 4: calculate      |  697          697    49.6s
    # Step 5: results        |   13     3     16     1.7s
    # RNG of the outermost testset: Xoshiro(0x1ffb60a255d629e8, 0x19eb25a45cb78b3f, 0xd541dc6bb3f64b83, 0x96433aadee5ffd34, 0xb3dcba6b746c31a0)
    # ERROR: Some tests did not pass: 3500 passed, 3 failed, 0 errored, 0 broken.
    # WARNING: Detected access to binding `Main.stepwise_test_4` in a world prior to its definition world.
    # Julia 1.12 has introduced more strict world age semantics for global bindings.
    # !!! This code may malfunction under Revise.
    # !!! This code will error in future versions of Julia.
    # Hint: Add an appropriate `invokelatest` around the access to this binding.
    # To make this warning an error, and hence obtain a stack trace, use `julia --depwarn=error`.

end