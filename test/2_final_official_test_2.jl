Test.@testset "2 - Pierce Schott 2016" begin

    # THIS TEST IS FAILING DUE TO A BUG IN THE ORIGINAL PACKAGE.
    
    using ReadStatTables
    using Downloads
    using DataFrames

    # Julia
    url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Pierce%20and%20Schott%202016/pierce_schott_didtextbook.dta"
    tmp = Downloads.download(url)
    data = ReadStatTables.readstat(tmp)
    data = DataFrames.DataFrame(data)

    # R
    # RCall.@rput url
    # RCall.rcopy(R"data = haven::read_dta(url)")

    data_1 = DataFrames.DataFrame(indusid = data.indusid, time = 1, Y = 0, D = 0)
    data_2 = DataFrames.DataFrame(indusid = data.indusid, time = 2, Y = data.delta2001, D = data.ntrgap)
    data = [data_1; data_2]
    RCall.@rput data

    # Julia:
    Y       = "Y"
    G       = "indusid"
    T       = "time"
    D       = "D"
    type    = "feTR"
    summary_measures = true 
    
    D0 = nothing
    controls = nothing
    treatments = nothing
    other_treatments = nothing
    random_weights = nothing

    # R
    RCall.rcopy(R"Y = 'Y'")
    RCall.rcopy(R"G = 'indusid'")
    RCall.rcopy(R"T = 'time'")
    RCall.rcopy(R"D = 'D'")
    RCall.rcopy(R"type = 'feTR'")
    RCall.rcopy(R"summary_measures = TRUE")

    RCall.rcopy(R"D0 = NULL")
    RCall.rcopy(R"controls = NULL")
    RCall.rcopy(R"treatments = NULL")
    RCall.rcopy(R"other_treatments = NULL")
    RCall.rcopy(R"random_weights = NULL")

    # Sanity check: 

    ## I - Renaming:
    # Julia
    controls_rename         = TwoWayFEWeights.get_controls_rename(controls)
    treatments_rename       = TwoWayFEWeights.get_treatments_rename(other_treatments)
    random_weight_rename    = TwoWayFEWeights.get_random_weight_rename(test_random_weights)
    data_renamed            = TwoWayFEWeights.twowayfeweights_rename_var(df = data, Y = Y, G = G, T = T, D = D, D0 = D0, controls = controls, treatments = treatments, random_weights = random_weights)
    data_renamed            = dropmissing!(data_renamed)

    # R
    RCall.rcopy(R"controls_rename           = TwoWayFEWeights:::get_controls_rename(controls)")
    RCall.rcopy(R"treatments_rename         = TwoWayFEWeights:::get_treatments_rename(other_treatments)")
    RCall.rcopy(R"random_weight_rename      = TwoWayFEWeights:::get_random_weight_rename(test_random_weights)")
    RCall.rcopy(R"data_renamed = TwoWayFEWeights:::twowayfeweights_rename_var(data, Y, G, T, D, D0, controls, other_treatments, random_weights = random_weights)")
    RCall.rcopy(R"data_renamed <- tidyr::drop_na(data_renamed)")

    # TEST
    Test.@test controls_rename          == RCall.rcopy(R"controls_rename           ")
    Test.@test treatments_rename        == RCall.rcopy(R"treatments_rename         ")
    Test.@test random_weight_rename     == RCall.rcopy(R"random_weight_rename      ")

    Test.@test data_renamed             == RCall.rcopy(R"data_renamed      ")

    # Stata 2 : 
    # twowayfeweights delta2001 indusid cons ntrgap ntrgap, type(fdTR)
    
    test_2_julia = twowayfeweights(
        data    = data,
        Y       = "Y",
        G       = "indusid",
        T       = "time",
        D       = "D",
        D0      = D0,
        type    = "feTR"
    )

    test_2_R = RCall.rcopy(R"TwoWayFEWeights::twowayfeweights(
        data        = data,
        Y           = 'Y',
        G           = 'indusid',
        T           = 'time',
        D           = 'D',
        D0          = D0,
        type        = 'feTR'
    )")

    @test test_2_julia == test_2_R
    for cc in keys(test_2_julia)
        if cc ∈ keys(test_2_R)
            if test_2_julia[cc] == test_2_R[cc]
                print("No problem with: ", cc, "\n")
            else
                print("Problem with: ", cc, "\n")
            end
        end
    end

end;