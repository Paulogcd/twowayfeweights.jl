Test.@testset "1 - Wolfers 2006" begin

    using ReadStatTables
    using Downloads
    using DataFrames
    using CSV
    using RCall

    # Julia
    url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Wolfers%202006/wolfers2006_didtextbook.dta"
    tmp = Downloads.download(url)
    data = ReadStatTables.readstat(tmp)
    data = DataFrames.DataFrame(data)

    # R
    RCall.@rput tmp
    RCall.rcopy(R"
        data = haven::read_dta(tmp)
    ")
    # RCall.rcopy(R"data <- haven::read_dta(tmp)")

    # Julia:
    other_treatments = ["rel_time$(i)" for i in 2:16]
    controls = ["rel_timeminus$(i)" for i in 1:9]
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
    RCall.rcopy(R"controls = paste0('rel_timeminus', 1:9)")
    RCall.rcopy(R"weights = data$stpop")
    RCall.rcopy(R"other_treatments = paste0('rel_time', 2:16)")

    # Stata syntax
    # twowayfeweights Y G T D [D0], type(string)
    #   [summary_measures test_random_weights(varlist)
    #   controls(varlist) other_treatments(varlist) weight(varlist) path(string)]

    # Stata 1 : 
    # twowayfeweights div_rate state year rel_time1, type(feTR) test_random_weights(year) weight(stpop) other_treatments(rel_time2-rel_time16) controls(rel_timeminus1-rel_timeminus9)
    
    test_1_julia = TwoWayFEWeights.twowayfeweights(
        data                = data,
        Y                   = "div_rate", 
        G                   = "state",
        T                   = "year",
        D                   = "rel_time1",
        type                = "feTR",
        test_random_weights = "year",
        weights             = weights,
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
        weights     = weights,
        other_treatments = other_treatments,
        controls    = controls
    )")

    @test isequal(test_1_R, test_1_julia)
end;