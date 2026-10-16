Test.@testset "4 - Gentzkow et al. 2011" begin
    
    using ReadStatTables
    using Downloads
    using DataFrames
    # using RData

    # Julia
    data = CSV.read(joinpath(@__DIR__, "data", "2_official_test_3_data_original.csv"), DataFrames.DataFrame)
    RCall.@rput data
    RCall.rcopy(R"styr_cols<- paste0(\"styr_\", levels(factor(data$styr)))")
    styr_cols = RCall.rcopy(R"styr_cols")
    
    test_4_R = RCall.rcopy(R"
        TwoWayFEWeights::twowayfeweights(
            data    = data,
            Y       = 'prestout',
            G       = 'cnty90',
            T       = 'year',
            D       = 'numdailies',
            type    = 'feTR',
            controls = styr_cols)")
    
    test_4_julia = twowayfeweights(
        data    = data,
        Y       = "prestout",
        G       = "cnty90",
        T       = "year",
        D       = "numdailies",
        type    = "feTR",
        controls = styr_cols
    )

    for cc in keys(test_4_julia)
        if cc ∈ keys(test_4_R)
            test_4_julia[cc] == test_4_R[cc]
            if test_4_julia[cc] == test_4_R[cc]
                print("No problem with: ", cc, "\n")
            else
                print("Problem with: ", cc, "\n")
                print("R:", test_4_R[cc], " and Julia: ", test_4_julia[cc], "\n")
            end
        end
    end
    test_4_julia = OrderedCollections.OrderedDict(test_4_julia)
    compare_R_julia(test_4_R, test_4_julia)
    @test test_4_julia == test_4_R

    test_result(test_4_R, test_4_julia)
    
end;