function stepwise_test_2()
    # Initialisation : 
    data = CSV.read(joinpath(@__DIR__, "data", "2_official_test_2_data.csv"), DataFrame)
    RCall.@rput data

    data_julia = Dict(
        :data                   => data,
        :Y                      => "Y",
        :G                      => "indusid",
        :T                      => "time",
        :D                      => "D",
        :type                   => "feTR",
        :D0                     => nothing,
        :summary_measures       => true,
        :controls               => nothing,
        :weights                => nothing,
        :other_treatments       => nothing,
        :test_random_weights    => nothing,
        :path                   => nothing,
    )

    RCall.rcopy(R"
        data_R = list(
            data                   = data,
            Y                      = \"Y\",
            G                      = \"indusid\",
            T                      = \"time\",
            D                      = \"D\",
            type                   = \"feTR\",
            D0                     = NULL,
            summary_measures       = TRUE,
            controls               = NULL,
            weights                = NULL,
            other_treatments       = NULL,
            test_random_weights    = NULL,
            path                   = NULL
        )
    ")
    data_R = RCall.rcopy(R"data_R")
    Test.@testset "Stepwise official test 2" begin
        data_R, data_julia = test_step_1_renaming(data_R, data_julia);
        data_R, data_julia = test_step_2_transform(data_R, data_julia);
        data_R, data_julia = test_step_3_filter(data_R, data_julia);
        data_R, data_julia = test_step_4_calculate(data_R, data_julia);
        data_R, data_julia = test_step_5_result(data_R, data_julia);
    end
end
stepwise_test_2();