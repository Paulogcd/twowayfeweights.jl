function stepwise_test_4()

    Test.@testset "Stepwise official test 4" begin
        
        # Initialisation : 
        data = CSV.read(joinpath(@__DIR__, "data", "2_official_test_3_data_original.csv"), DataFrames.DataFrame)
        RCall.@rput data
        RCall.rcopy(R"styr_cols<- paste0(\"styr_\", levels(factor(data$styr)))")
        styr_cols = RCall.rcopy(R"styr_cols")
        
        data_julia = Dict(
            :data                   => data,
            :Y                      => "prestout",
            :G                      => "cnty90",
            :T                      => "year",
            :D                      => "changedailies",
            :D0                     => nothing,
            :type                   => "feTR",
            :controls               => styr_cols,
            :summary_measures       => true,
            :other_treatments       => nothing,
            :path                   => nothing,
            :test_random_weights    => nothing,
            :weights                => nothing
        )

        RCall.rcopy(R"data_R <- list(
            data = data,
            Y = 'prestout',
            G = 'cnty90',
            T = 'year',
            D = 'changedailies',
            D0 = NULL,
            type = 'feTR',
            controls = styr_cols,
            summary_measures = TRUE,
            other_treatments   = NULL,
            path               = NULL,
            test_random_weights = NULL,
            weights = NULL
        )")
        data_R = RCall.rcopy(R"data_R")

        data_R == data_julia
        for k in string.(keys(data_R))
            RCall.@rput k
            data_julia[Symbol(k)] == RCall.rcopy(R"data_R[[k]]")
        end

        data_R, data_julia = test_step_1_renaming(data_R, data_julia);
        data_R, data_julia = test_step_2_transform(data_R, data_julia);
        data_R, data_julia = test_step_3_filter(data_R, data_julia);
        data_R, data_julia = test_step_4_calculate(data_R, data_julia);
        data_R, data_julia = test_step_5_result(data_R, data_julia);
    end
end
stepwise_test_4();