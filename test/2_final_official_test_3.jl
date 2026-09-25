Test.@testset "3 - Gentzkow et al. 2011" begin

    # THIS TEST IS FAILING DUE TO A BUG IN THE ORIGINAL PACKAGE.
    
    using ReadStatTables
    using Downloads
    using DataFrames

    # Julia
    # url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Gentzkow%20et%20al%202011/gentzkowetal_didtextbook.dta"
    url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Gentzkow%20et%20al%202011/gentzkowetal_didtextbook.RData"
    tmp = Downloads.download(url)
    obj = RData.load(tmp)
    data = obj["df"]
    data = DataFrames.DataFrame(data)

    # This test requires a little adjustement regarding the controls "styr":

    # R
    RCall.@rput data
    RCall.rcopy(R"

        df <- fastDummies::dummy_cols(data, select_columns = 'styr', remove_first_dummy = FALSE)
        df <- fastDummies::dummy_cols(df, select_columns = 'styr',
                 remove_first_dummy = FALSE,
                 remove_selected_columns = FALSE)
    
        # Crear dummies
        styr_dummies <- model.matrix(~factor(df$styr) - 1)
        colnames(styr_dummies) <- paste0('styr_', levels(factor(df$styr)))
        styr_cols<- paste0('styr_', levels(factor(df$styr)))
        # Unirlas al dataframe original
        df <- cbind(df, styr_dummies)

        decomp3 <- TwoWayFEWeights::twowayfeweights(df, 'changeprestout', 'cnty90', 'year',
                                'changedailies', D0 = 'numdailies',
                                type = 'fdTR', controls = styr_cols)")
    test_3_R = RCall.rcopy(R"decomp3")
    styr_cols = RCall.rcopy(R"styr_cols")
    
    data_copy = copy(data)
    for xx in unique(data[:, :styr])
        DataFrames.transform!(data_copy, :styr => ((x) -> x == xx ? 1 : 0) => string("styr_", Int64(xx)))
    end

    test_3_julia = twowayfeweights(data = data_copy,
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
    
    for cc in keys(test_3_julia)
        if cc ∈ keys(test_3_R)
            if test_3_julia[cc] == test_3_R[cc]
                print("No problem with: ", cc, "\n")
            else
                print("Problem with: ", cc, "\n")
            end
        end
    end
end;