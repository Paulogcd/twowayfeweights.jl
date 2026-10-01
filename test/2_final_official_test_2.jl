Test.@testset "2 - Pierce Schott 2016" begin

    using ReadStatTables
    using Downloads
    using DataFrames
    using CSV

    # Data loading
    data = CSV.read(joinpath(@__DIR__, "data", "2_official_test_2_data.csv"), DataFrame)
    RCall.@rput data

    # Stata 2 : 
    # twowayfeweights delta2001 indusid cons ntrgap ntrgap, type(fdTR)
    
    test_2_julia = TwoWayFEWeights.twowayfeweights(
        data    = data,
        Y       = "Y",
        G       = "indusid",
        T       = "time",
        D       = "D",
        type    = "feTR",
        summary_measures = true
    )

    test_2_R = RCall.rcopy(R"
        TwoWayFEWeights::twowayfeweights(
            data        = data,
            Y           = \"Y\",
            G           = \"indusid\",
            T           = \"time\",
            D           = \"D\",
            type        = \"feTR\",
            summary_measures = TRUE
        )"
    )

    @test isequal(test_2_R, test_2_julia)
    keys(test_2_R)
    keys(test_2_julia)
    for k in intersect(keys(test_2_R), keys(test_2_julia))
        print(k, " : ", test_2_R[k] == test_2_julia[k], "\n")
    end

end;