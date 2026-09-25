Test.@testset "1 - Wolfers 2006" begin

    using ReadStatTables
    using Downloads
    using DataFrames

    # Julia
    url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Wolfers%202006/wolfers2006_didtextbook.dta"
    tmp = Downloads.download(url)
    data = ReadStatTables.readstat(tmp)
    data = DataFrames.DataFrame(data)

    # R
    RCall.@rput url
    RCall.rcopy(R"data = haven::read_dta(url)")

    # Julia:
    other_treatments = [
        "rel_time2",
        "rel_time3",
        "rel_time4",
        "rel_time5",
        "rel_time6",
        "rel_time7",
        "rel_time8",
        "rel_time9",
        "rel_time10",
        "rel_time11",
        "rel_time12",
        "rel_time13",
        "rel_time14",
        "rel_time15",
        "rel_time16"
    ]

    controls = [
        "rel_timeminus1", 
        "rel_timeminus2", 
        "rel_timeminus3", 
        "rel_timeminus4", 
        "rel_timeminus5", 
        "rel_timeminus6", 
        "rel_timeminus7", 
        "rel_timeminus8", 
        "rel_timeminus9"
    ]

    Y       = "div_rate"
    G       = "state"
    T       = "year"
    D       = "rel_time1"
    D0      = nothing
    type    = "feTR"
    test_random_weights = "year"
    weights             = data.stpop

    # R
    RCall.rcopy(R"Y = 'div_rate'")
    RCall.rcopy(R"G = 'state'")
    RCall.rcopy(R"T = 'year'")
    RCall.rcopy(R"D = 'rel_time1'")
    RCall.rcopy(R"type = 'feTR'")
    RCall.rcopy(R"D0 = NULL")
    RCall.rcopy(R"summary_measures = TRUE")
    RCall.rcopy(R"test_random_weights = 'year'")
    RCall.rcopy(R"controls = c(
        'rel_timeminus1', 
        'rel_timeminus2', 
        'rel_timeminus3', 
        'rel_timeminus4', 
        'rel_timeminus5', 
        'rel_timeminus6', 
        'rel_timeminus7', 
        'rel_timeminus8', 
        'rel_timeminus9')")
    RCall.rcopy(R"weights = data$stpop")
    RCall.rcopy(R"other_treatments = c(
        'rel_time2',
        'rel_time3',
        'rel_time4',
        'rel_time5',
        'rel_time6',
        'rel_time7',
        'rel_time8',
        'rel_time9',
        'rel_time10',
        'rel_time11',
        'rel_time12',
        'rel_time13',
        'rel_time14',
        'rel_time15',
        'rel_time16')")

    # Sanity check: 

    ## I - Renaming:
    # Julia
    controls_rename         = TwoWayFEWeights.get_controls_rename(controls)
    treatments_rename       = TwoWayFEWeights.get_treatments_rename(other_treatments)
    random_weight_rename    = TwoWayFEWeights.get_random_weight_rename(test_random_weights)
    data_renamed            = TwoWayFEWeights.twowayfeweights_rename_var(df = data, Y = Y, G = G, T = T, D = D, D0 = D0, controls = controls, treatments = other_treatments, random_weights = test_random_weights)
    data_renamed            = dropmissing!(data_renamed)

    # R
    RCall.rcopy(R"controls_rename           = TwoWayFEWeights:::get_controls_rename(controls)")
    RCall.rcopy(R"treatments_rename         = TwoWayFEWeights:::get_treatments_rename(other_treatments)")
    RCall.rcopy(R"random_weight_rename      = TwoWayFEWeights:::get_random_weight_rename(test_random_weights)")
    RCall.rcopy(R"data_renamed = TwoWayFEWeights:::twowayfeweights_rename_var(data, Y, G, T, D, D0, controls, other_treatments, test_random_weights)")
    RCall.rcopy(R"data_renamed <- tidyr::drop_na(data_renamed)")

    # TEST
    Test.@test controls_rename          == RCall.rcopy(R"controls_rename           ")
    Test.@test treatments_rename        == RCall.rcopy(R"treatments_rename         ")
    Test.@test random_weight_rename     == RCall.rcopy(R"random_weight_rename      ")

    Test.@test data_renamed             == RCall.rcopy(R"data_renamed      ")

    ## II - 


    # Stata syntax
    # twowayfeweights Y G T D [D0], type(string)
    #   [summary_measures test_random_weights(varlist)
    #   controls(varlist) other_treatments(varlist) weight(varlist) path(string)]

    # Stata 1 : 
    # twowayfeweights div_rate state year rel_time1, type(feTR) test_random_weights(year) weight(stpop) other_treatments(rel_time2-rel_time16) controls(rel_timeminus1-rel_timeminus9)
    
    test_1_julia = twowayfeweights(
        data                = data,
        Y                   = "div_rate", 
        G                   = "state",
        T                   = "year",
        D                   = "rel_time1",
        type                = "feTR",
        test_random_weights = "year",
        weights             = data.stpop,
        other_treatments    = other_treatments,
        controls            = controls)

    test_1_R = RCall.rcopy(R"TwoWayFEWeights::twowayfeweights(
        data        = data,
        Y           = 'div_rate',
        G           = 'state',
        T           = 'year',
        D           = 'rel_time1',
        type        = 'feTR',
        test_random_weights = 'year',
        weights     = data$'stpop',
        other_treatments = other_treatments,
        controls    = controls
    )")

    for cc in keys(test_1_julia)
        if cc ∈ keys(test_1_R)
            if typeof(test_1_julia[cc]) <: Number
                if test_1_julia[cc] ≈ test_1_R[cc]
                    print("Number - No problem with: ", cc, "\n")
                    true
                else
                    print("Number - Problem with: ", cc, "\n")
                    false
                end
            else
                if test_1_julia[cc] == test_1_R[cc]
                    print("No problem with: ", cc, "\n")
                    true
                else
                    print("Problem with: ", cc, "\n")
                    false
                end
            end
        end
    end
end;