Test.@testset "Stepwise official test" begin
    include("./3_2_stepwise_test_1.jl"); # 1 test fails at step 5 - result:
    #     Step 5: results: Error During Test at /Users/paulogcd/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:223
    #   Got exception outside of a @test
    #   MethodError: no method matching compare_R_julia(::Nothing, ::OrderedDict{Symbol, Any})
    #   The function `compare_R_julia` exists, but no method is defined for this combination of argument types.
    #   Closest candidates are:
    #     compare_R_julia(::AbstractDict, ::AbstractDict)
    #      @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:272
    #     compare_R_julia(::DataFrame, ::DataFrame)
    #      @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:328
    #   Stacktrace:
    #     [1] compare_R_julia(R_object::OrderedDict{Symbol, Any}, julia_object::OrderedDict{Symbol, Any})
    #       @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:294
    #     [2] macro expansion
    #       @ ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:248 [inlined]
    #     [3] macro expansion
    #       @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:1967 [inlined]
    #     [4] test_step_5_result(data_R::OrderedDict{Symbol, Any}, data_julia::Dict{Symbol, Any}, save::Bool)
    #       @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:225
    #     [5] test_step_5_result(data_R::OrderedDict{Symbol, Any}, data_julia::Dict{Symbol, Any})
    #       @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:223
    #     [6] macro expansion
    #       @ ~/twowayfeweights.jl/test/3_2_stepwise_test_1.jl:51 [inlined]
    #     [7] macro expansion
    #       @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:1967 [inlined]
    #     [8] stepwise_test_1()
    #       @ Main ~/twowayfeweights.jl/test/3_2_stepwise_test_1.jl:6
    #     [9] top-level scope
    #       @ ~/twowayfeweights.jl/test/3_2_stepwise_test_1.jl:54
    #    [10] include(mapexpr::Function, mod::Module, _path::String)
    #       @ Base ./Base.jl:310
    #    [11] top-level scope
    #       @ ~/twowayfeweights.jl/test/3_final_stepwise_official_test.jl:2
    #    [12] eval(m::Module, e::Any)
    #       @ Core ./boot.jl:489
    #    [13] include_string(mapexpr::typeof(REPL.softscope), mod::Module, code::String, filename::String)
    #       @ Base ./loading.jl:3033
    #    [14] inlineeval(m::Module, code::String, code_line::Int64, code_column::Int64, file::String; softscope::Bool)
    #       @ VSCodeServer ~/.vscode/extensions/julialang.language-julia-1.249.2/scripts/packages/VSCodeServer/src/eval.jl:296
    #    [15] (::VSCodeServer.var"#repl_runcode_request##6#repl_runcode_request##7"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeRequestParams})()
    #       @ VSCodeServer ~/.vscode/extensions/julialang.language-julia-1.249.2/scripts/packages/VSCodeServer/src/eval.jl:202
    #    [16] withpath(f::VSCodeServer.var"#repl_runcode_request##6#repl_runcode_request##7"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeRequestParams}, path::String)
    #       @ VSCodeServer ~/.vscode/extensions/julialang.language-julia-1.249.2/scripts/packages/VSCodeServer/src/repl.jl:338
    #    [17] (::VSCodeServer.var"#repl_runcode_request##4#repl_runcode_request##5"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeRequestParams})()
    #       @ VSCodeServer ~/.vscode/extensions/julialang.language-julia-1.249.2/scripts/packages/VSCodeServer/src/eval.jl:200
    #    [18] hideprompt(f::VSCodeServer.var"#repl_runcode_request##4#repl_runcode_request##5"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeRequestParams})
    #       @ VSCodeServer ~/.vscode/extensions/julialang.language-julia-1.249.2/scripts/packages/VSCodeServer/src/repl.jl:38
    #    [19] #repl_runcode_request##2
    #       @ ~/.vscode/extensions/julialang.language-julia-1.249.2/scripts/packages/VSCodeServer/src/eval.jl:171 [inlined]
    #    [20] with_logstate(f::VSCodeServer.var"#repl_runcode_request##2#repl_runcode_request##3"{Bool, Bool, Bool, Module, String, Int64, Int64, String, VSCodeServer.ReplRunCodeRequestParams}, logstate::Base.CoreLogging.LogState)
    #       @ Base.CoreLogging ./logging/logging.jl:542
    #    [21] with_logger
    #       @ ./logging/logging.jl:653 [inlined]
    #    [22] (::VSCodeServer.var"#repl_runcode_request##0#repl_runcode_request##1"{VSCodeServer.ReplRunCodeRequestParams})()
    #       @ VSCodeServer ~/.vscode/extensions/julialang.language-julia-1.249.2/scripts/packages/VSCodeServer/src/eval.jl:284
    #    [23] (::VSCodeServer.var"#start_eval_backend##0#start_eval_backend##1")()
    #       @ VSCodeServer ~/.vscode/extensions/julialang.language-julia-1.249.2/scripts/packages/VSCodeServer/src/eval.jl:34
    # Test Summary:            | Pass  Error  Total  Time
    # Stepwise official test 1 |  227      1    228  1.4s
    #   Step 1: renaming       |   85            85  0.0s
    #   Step 2: transforming   |   33            33  0.4s
    #   Step 3: filtering      |   33            33  0.0s
    #   Step 4: calculate      |   54            54  0.9s
    #   Step 5: results        |   22      1     23  0.0s
    # RNG of the outermost testset: Xoshiro(0x49a1998c9079927b, 0xd94b21d8c96cd020, 0x467c9b4d704c12e6, 0xccbd8f02748276e3, 0xcf20f0ab4dcda18e)
    # ERROR: LoadError: Some tests did not pass: 227 passed, 0 failed, 1 errored, 0 broken.
    # in expression starting at /Users/paulogcd/twowayfeweights.jl/test/3_2_stepwise_test_1.jl:54

    include("./3_2_stepwise_test_2.jl"); # Everything passes

    include("./3_2_stepwise_test_3.jl"); # 1 test fails at step 5 - result
    # ┌ Warning: RCall.jl: Warning in as.numeric(data_R$data[[v]]) : NAs introduced by coercion
    # │ Warning in as.numeric(data_R$data[[v]]) : NAs introduced by coercion
    # └ @ RCall ~/.julia/packages/RCall/uXeD3/src/io.jl:166
    # ┌ Warning: JSON-RPC endpoint has been blocked writing to its peer; outgoing messages are queueing up and will not be delivered until the peer resumes reading
    # │   blocked_seconds = 95.5
    # │   queued_messages = 2
    # └ @ VSCodeServer.JSONRPC ~/.vscode/extensions/julialang.language-julia-1.249.2/scripts/packages/JSONRPC/src/core.jl:414
    # ┌ Warning: RCall.jl: NOTE: 1,245 observations removed because of NA values (LHS: 1,245).
    # │ The variables 'ctrl_styr_2175', 'ctrl_styr_2222', 'ctrl_styr_2223',
    # │ 'ctrl_styr_2224', 'ctrl_styr_2225', 'ctrl_styr_2226' and 9 others have been
    # │ removed because of collinearity (see $collin.var).
    # │ NOTE: 1,245 observations removed because of NA values (LHS: 1,245, RHS: 1,245).
    # └ @ RCall ~/.julia/packages/RCall/uXeD3/src/io.jl:166
    # k = "nr_plus"
    # eltype(julia_object_k) = Int64
    # eltype(R_object_k) = Int64
    # length(julia_object_k) = 1
    # length(R_object_k) = 1
    # maximum(abs.(julia_object_k .- R_object_k)) = 1

    # Step 5: results: Test Failed at /Users/paulogcd/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:315
    # Expression: result_approx
    # Stacktrace:
    # [1] macro expansion
    #     @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:758 [inlined]
    # [2] compare_R_julia(R_object::OrderedDict{Symbol, Any}, julia_object::OrderedDict{Symbol, Any})
    #     @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:315
    # [3] macro expansion
    #     @ ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:248 [inlined]
    # [4] macro expansion
    #     @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:1967 [inlined]
    # [5] test_step_5_result(data_R::OrderedDict{Symbol, Any}, data_julia::Dict{Symbol, Any}, save::Bool)
    #     @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:225
    # k = "nr_weights"
    # eltype(julia_object_k) = Int64
    # eltype(R_object_k) = Int64
    # length(julia_object_k) = 1
    # length(R_object_k) = 1
    # maximum(abs.(julia_object_k .- R_object_k)) = 1

    # Step 5: results: Test Failed at /Users/paulogcd/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:315
    # Expression: result_approx
    # Stacktrace:
    # [1] macro expansion
    #     @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:758 [inlined]
    # [2] compare_R_julia(R_object::OrderedDict{Symbol, Any}, julia_object::OrderedDict{Symbol, Any})
    #     @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:315
    # [3] macro expansion
    #     @ ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:248 [inlined]
    # [4] macro expansion
    #     @ ~/.julia/juliaup/julia-1.13.1+0.aarch64.apple.darwin14/Julia-1.13.app/Contents/Resources/julia/share/julia/stdlib/v1.13/Test/src/Test.jl:1967 [inlined]
    # [5] test_step_5_result(data_R::OrderedDict{Symbol, Any}, data_julia::Dict{Symbol, Any}, save::Bool)
    #     @ Main ~/twowayfeweights.jl/test/3_1_utils_test_stepwise.jl:225
    # Test Summary:            | Pass  Fail  Total     Time
    # Stepwise official test 3 | 3505     2   3507  9m46.7s
    # Step 1: renaming       | 1408         1408     3.2s
    # Step 2: transforming   |  693          693  7m53.5s
    # Step 3: filtering      |  692          692     2.4s
    # Step 4: calculate      |  698          698  1m44.5s
    # Step 5: results        |   14     2     16     2.0s
    # RNG of the outermost testset: Xoshiro(0x1dacfd765add44f5, 0x24b7b72e675a0415, 0x9540e1ebf5133858, 0x8c24a75b1bc6396c, 0x4b19201b1cb6fce0)
    # ERROR: LoadError: Some tests did not pass: 3505 passed, 2 failed, 0 errored, 0 broken.
    # in expression starting at /Users/paulogcd/twowayfeweights.jl/test/3_2_stepwise_test_3.jl:65
    # WARNING: Detected access to binding `Main.stepwise_test_3` in a world prior to its definition world.
    # Julia 1.12 has introduced more strict world age semantics for global bindings.
    # !!! This code may malfunction under Revise.
    # !!! This code will error in future versions of Julia.
    # Hint: Add an appropriate `invokelatest` around the access to this binding.
    # To make this warning an error, and hence obtain a stack trace, use `julia --depwarn=error`.

    include("./3_2_stepwise_test_4.jl"); # 1 test fails at step 5 - result: 
    #     Test Summary:            | Pass  Error  Total     Time
    # Stepwise official test 4 | 3486      1   3487  8m37.9s
    #   Step 1: renaming       | 1407          1407     2.9s
    #   Step 2: transforming   |  691           691  7m58.6s
    #   Step 3: filtering      |  691           691     2.5s
    #   Step 4: calculate      |  697           697    32.4s
    #   Step 5: results        |           1      1     0.3s
    # RNG of the outermost testset: Xoshiro(0x49a1998c9079927b, 0xd94b21d8c96cd020, 0x467c9b4d704c12e6, 0xccbd8f02748276e3, 0xcf20f0ab4dcda18e)
    # ERROR: LoadError: Some tests did not pass: 3486 passed, 0 failed, 1 errored, 0 broken.
    # in expression starting at /Users/paulogcd/twowayfeweights.jl/test/3_2_stepwise_test_4.jl:57
    # WARNING: Detected access to binding `Main.stepwise_test_4` in a world prior to its definition world.
    #   Julia 1.12 has introduced more strict world age semantics for global bindings.
    #   !!! This code may malfunction under Revise.
    #   !!! This code will error in future versions of Julia.
    # Hint: Add an appropriate `invokelatest` around the access to this binding.
    # To make this warning an error, and hence obtain a stack trace, use `julia --depwarn=error`.

end