function stepwise_test_3()

    Test.@testset "Stepwise official test 3" begin
        
        # Initialisation : 
        data = CSV.read(joinpath(@__DIR__, "data", "2_official_test_3_data_original.csv"), DataFrames.DataFrame)
        RCall.@rput data
        RCall.rcopy(R"styr_cols <- paste0(\"styr_\", levels(factor(data$styr)))")
        styr_cols = RCall.rcopy(R"styr_cols")

        data_julia = Dict(
            :data                   => data,
            
            :Y                      => "changeprestout",
            :G                      => "cnty90",
            :T                      => "year",
            :D                      => "changedailies",
            :D0                     => "numdailies",
            
            :type                   => "fdTR",

            :controls               => styr_cols,
            :weights                => nothing,
            :other_treatments       => nothing,
            :test_random_weights    => nothing,
            
            :summary_measures       => true,
            :path                   => nothing,
        )
        
        RCall.rcopy(R"data_R <- list(
            data                = data,

            Y                   = 'changeprestout',
            G                   = 'cnty90',
            T                   = 'year',
            D                   = 'changedailies',
            D0                  = 'numdailies',
            
            type                = 'fdTR',
            
            controls            = styr_cols,
            weights             = NULL,
            other_treatments    = NULL,
            test_random_weights = NULL,
            
            summary_measures    = TRUE,
            path                = NULL
        )")
        data_R = RCall.rcopy(R"data_R")

        data_R == data_julia
        for k in string.(keys(data_R))
            RCall.@rput k
            data_julia[Symbol(k)] == RCall.rcopy(R"data_R[[k]]")
        end

        data_R, data_julia = test_step_1_renaming(  data_R, data_julia);
        data_R, data_julia = test_step_2_transform( data_R, data_julia);
        data_R, data_julia = test_step_3_filter(    data_R, data_julia);
        data_R, data_julia = test_step_4_calculate( data_R, data_julia);
        # data_julia = JLD2.load(joinpath("/Users/paulogcd/twowayfeweights.jl/test/data/output/data_julia_4.jld2"))["data_julia"]
        # data_R = RCall.rcopy(R"base::readRDS('/Users/paulogcd/twowayfeweights.jl/test/data/output/data_R_4.rds')")
        # setdiff(keys(data_julia), keys(data_R))
        data_R, data_julia = test_step_5_result(    data_R, data_julia); # Here lie 2 errors.
    end
end
stepwise_test_3();