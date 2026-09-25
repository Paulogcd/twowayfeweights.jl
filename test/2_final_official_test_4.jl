Test.@testset "4 - Gentzkow et al. 2011" begin
    
    using ReadStatTables
    using Downloads
    using DataFrames
    using RData

    # Julia
    data = CSV.read("./test/data/2_official_test_4_data_original.csv", DataFrame)
    RCall.@rput data
    
    # Stata syntax
    # twowayfeweights Y G T D [D0], type(string)
    #   [summary_measures test_random_weights(varlist)
    #   controls(varlist) other_treatments(varlist) weight(varlist) path(string)]

    # Stata 4 : 
    # twowayfeweights prestout cnty90 year numdailies, type(feTR) controls(styr1-styr683)
    
    test_4_R = RCall.rcopy(R"
        TwoWayFEWeights::twowayfeweights(
            data = data,
            Y = 'prestout',
            G = 'cnty90',
            T = 'year',
            D = 'changedailies',
            D0 = 'numdailies',
            type = 'fdTR',
            controls = styr_cols)")
    # ERROR: REvalError: NOTE: 1,245 observations removed because of NA values (LHS: 1,245).
    # Error: in fixest::feols(fml, data = dt, weights = dt$weight...: 
    # Error : in select_obs_rm0s(linear.mat, -obs2remove, nthreads...: 
    # After removing NAs, not a single explanatory variable is different from 0.
    # This error was unforeseen by the author of the function feols. If you think
    # your call to the function is legitimate, could you report?┌ Warning: JSON-RPC endpoint has been blocked writing to its peer; outgoing messages are queueing up and will not be delivered until the peer resumes reading
    # │   blocked_seconds = 458.6
    # │   queued_messages = 1
    # └ @ VSCodeServer.JSONRPC ~/.vscode/extensions/julialang.language-julia-1.243.2/scripts/packages/JSONRPC/src/core.jl:414

    # Stacktrace:
    #  [1] handle_eval_stderr(; as_warning::Bool)
    #    @ RCall ~/.julia/packages/RCall/fTLHT/src/io.jl:168
    #  [2] handle_eval_stderr
    #    @ ~/.julia/packages/RCall/fTLHT/src/io.jl:162 [inlined]
    #  [3] reval_p(expr::Ptr{LangSxp}, env::Ptr{EnvSxp})
    #    @ RCall ~/.julia/packages/RCall/fTLHT/src/eval.jl:111
    #  [4] reval_p(expr::Ptr{RCall.ExprSxp}, env::Ptr{EnvSxp})
    #    @ RCall ~/.julia/packages/RCall/fTLHT/src/eval.jl:127
    #  [5] reval(str::String, env::RObject{EnvSxp})
    #    @ RCall ~/.julia/packages/RCall/fTLHT/src/eval.jl:145
    #  [6] top-level scope
    #    @ ~/twowayfeweights.jl/test/2_final_official_test_4.jl:0
    #  [7] macro expansion
    #    @ ~/.julia/packages/RCall/fTLHT/src/macros.jl:75 [inlined]
    
    test_4_julia = twowayfeweights(
        data = data_copy,
        Y = "prestout",
        G = "cnty90",
        T = "year",
        D = "numdailies",
        type = "feTR",
        controls = styr_cols
    )

    for cc in keys(test_4_julia)
        if cc ∈ keys(test_4_R)
            @test test_4_julia[cc] == test_4_R[cc]
            if test_4_julia[cc] == test_4_R[cc]
                print("No problem with: ", cc, "\n")
            else
                print("Problem with: ", cc, "\n")
            end
        end
    end

    @test test_4_julia == test_4_R
    
end;