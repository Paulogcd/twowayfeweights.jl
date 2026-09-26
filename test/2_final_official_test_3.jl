Test.@testset "3 - Gentzkow et al. 2011" begin

    # Initially, this test was failing due a discrepancy between the R and the Stata
    # package. Now, the Really Credible Team (Anzony Quispe) provided me with a code
    # to replicate the Stata code in R.
    
    using ReadStatTables
    using Downloads
    using DataFrames
    using CSV

    # Data loading
    data = CSV.read(joinpath(@__DIR__,"data", "2_official_test_3_data_original.csv"), DataFrames.DataFrame)
    RCall.@rput data
    RCall.rcopy(R"styr_cols<- paste0(\"styr_\", levels(factor(data$styr)))")
    styr_cols = RCall.rcopy(R"styr_cols")

    RCall.rcopy(R"test_3_R <- TwoWayFEWeights::twowayfeweights(
                    data        = data,
                    Y           = 'changeprestout',
                    G           = 'cnty90',
                    T           = 'year',
                    D           = 'changedailies',
                    D0          = 'numdailies',
                    type        = 'fdTR',
                    controls    = styr_cols)")
    test_3_R = RCall.rcopy(R"test_3_R")

    test_3_julia = twowayfeweights(data = data,
        Y = "changeprestout",
        G = "cnty90",
        T = "year",
        D = "changedailies",
        D0 = "numdailies",
        type = "fdTR",
        controls = styr_cols
    ) # ERROR: DomainError with -2.2517998136852222e15:
    
    # Stata syntax
    # twowayfeweights Y G T D [D0], type(string)
    #   [summary_measures test_random_weights(varlist)
    #   controls(varlist) other_treatments(varlist) weight(varlist) path(string)]

    # Stata 3 : 
    # twowayfeweights changeprestout cnty90 year changedailies numdailies, type(fdTR) controls(styr1-styr683)
    
    # for cc in keys(test_3_julia)
    #     if cc ∈ keys(test_3_R)
    #         if test_3_julia[cc] == test_3_R[cc]
    #             print("No problem with: ", cc, "\n")
    #         else
    #             print("Problem with: ", cc, "\n")
    #         end
    #     end
    # end
    test_result(test_3_R, test_3_julia)
end;