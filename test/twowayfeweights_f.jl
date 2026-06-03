@testset twowayfeweightsTEST begin

    using ReadStatTables

    # For this test, we are going to use the official / original 
    # code snipped used in the original package.
    repo = "chaisemartinPackages/twowayfeweights/main"
    file = "wagepan_twfeweights.dta"
    url = "https://raw.githubusercontent.com" * "/" * repo * "/" * file
    path = download(url)
    wagepan = ReadStatTables.readstat(path)
    wagepan = DataFrames.DataFrame(wagepan)

    resultat = twowayfeweights(
        data = wagepan,
        Y = "lwage",
        G = "nr",
        T = "year",
        D = "union",
        type = "feTR",
        summary_measures = true,
        test_random_weights = "educ")

    resultat_2 = twowayfeweights(
        data = wagepan,
        Y = "lwage",
        G = "nr",
        T = "year",
        D = "union",
        type = "feS",
        summary_measures = true,
        test_random_weights = "educ")

    data = wagepan
    Y = "lwage"
    G = "nr"
    T = "year"
    D = "union"
    type = "feS"
    summary_measures = true
    test_random_weights = "educ"

    D0 = nothing
    controls = nothing
    weights = nothing
    other_treatments = nothing
    path = nothing

    RCall.@rput wagepan
    Test.@test wagepan == RCall.rcopy(R"wagepan")

    julia_code_result = twowayfeweights(
        data = wagepan,
        Y = "lwage",
        G = "nr",
        T = "year",
        D = "union",
        type = "feTR",
        summary_measures = true,
        test_random_weights = "educ")

    R_code_result = RCall.rcopy(R"TwoWayFEWeights::twowayfeweights(
        wagepan,                        # input data
        'lwage', # Y
        'nr', # G
        'year', # T
        'union', # D
        type                = 'feTR', 
        summary_measures    = TRUE,   
        test_random_weights = 'educ'  
    )")

    @test R_code_result == julia_code_result

    Test.@test julia_code_result[:nr_minus]            == R_code_result[:nr_minus]
    Test.@test julia_code_result[:nr_weights]          == R_code_result[:nr_weights]
    Test.@test julia_code_result[:sum_plus]            == R_code_result[:sum_plus]
    Test.@test julia_code_result[:sum_minus]           == R_code_result[:sum_minus]
    Test.@test julia_code_result[:dat_result]          == R_code_result[:dat_result]
    Test.@test julia_code_result[:beta]                == R_code_result[:beta]
    Test.@test julia_code_result[:sensibility]         == R_code_result[:sensibility]
    Test.@test julia_code_result[:mat]                 == R_code_result[:mat]
    Test.@test julia_code_result[:sensibility2]        == R_code_result[:sensibility2]
    Test.@test julia_code_result[:tot_cells]           == R_code_result[:tot_cells]
    Test.@test julia_code_result[:type]                == R_code_result[:type]
    Test.@test julia_code_result[:params]              == R_code_result[:params]
    Test.@test julia_code_result[:summary_measures]    == R_code_result[:summary_measures]
    Test.@test julia_code_result[:other_treatments]    == R_code_result[:other_treatments]
    Test.@test julia_code_result[:random_weights]      == R_code_result[:random_weights]


end