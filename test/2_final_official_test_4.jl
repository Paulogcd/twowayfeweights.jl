Test.@testset "4 - Gentzkow et al. 2011" begin
    
    using ReadStatTables
    using Downloads
    using DataFrames

    # Julia
    url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Gentzkow%20et%20al%202011/gentzkowetal_didtextbook.RData"
    tmp = Downloads.download(url)
    obj = RData.load(tmp)
    data = obj["df"]
    data = DataFrames.DataFrame(data)

    # This test requires a little adjustement regarding the controls "styr":

    # R
    # RCall.@rput data
    # RCall.rcopy(R"

    #     df <- fastDummies::dummy_cols(data, select_columns = 'styr', remove_first_dummy = FALSE)
    #     df <- fastDummies::dummy_cols(df, select_columns = 'styr',
    #              remove_first_dummy = FALSE,
    #              remove_selected_columns = FALSE)
    
    #     # Crear dummies
    #     styr_dummies <- model.matrix(~factor(df$styr) - 1)
    #     colnames(styr_dummies) <- paste0('styr_', levels(factor(df$styr)))
    #     styr_cols<- paste0('styr_', levels(factor(df$styr)))
    #     # Unirlas al dataframe original
    #     df <- cbind(df, styr_dummies)

    #     test_4_R <- TwoWayFEWeights::twowayfeweights(df,
    #         Y = 'prestout',
    #         G = 'cnty90',
    #         T = 'year',
    #         D = 'changedailies',
    #         D0 = 'numdailies',
    #         type = 'fdTR',
    #         controls = styr_cols)")

    test_4_R = RCall.rcopy(R"test_4_R")
    styr_cols = RCall.rcopy(R"styr_cols")
    
    data_copy = copy(data)
    for xx in unique(data[:, :styr])
        DataFrames.transform!(data_copy, :styr => ((x) -> x == xx ? 1 : 0) => string("styr_", Int64(xx)))
    end
    RCall.@rput data_copy

    test_4_julia = twowayfeweights(
        data = data_copy,
        Y = "prestout",
        G = "cnty90",
        T = "year",
        D = "numdailies",
        type = "feTR",
        controls = styr_cols
    )

    test_4_R = RCall.rcopy(R"
        TwoWayFEWeights::twowayfeweights(
            data = data_copy,
            Y = 'prestout',
            G = 'cnty90',
            T = 'year',
            D = 'changedailies',
            D0 = 'numdailies',
            type = 'fdTR',
            controls = styr_cols)")
    
    # Stata syntax
    # twowayfeweights Y G T D [D0], type(string)
    #   [summary_measures test_random_weights(varlist)
    #   controls(varlist) other_treatments(varlist) weight(varlist) path(string)]

    # Stata 4 : 
    # twowayfeweights prestout cnty90 year numdailies, type(feTR) controls(styr1-styr683)
    
    for cc in keys(test_4_julia)
        if cc ∈ keys(test_4_R)
            if test_4_julia[cc] == test_4_R[cc]
                print("No problem with: ", cc, "\n")
            else
                print("Problem with: ", cc, "\n")
            end
        end
    end

    @test test_4_julia == test_4_R
    
end;