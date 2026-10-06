function stepwise_test_1()

    Test.@testset "Stepwise official test 1" begin
        
        # Initialisation :
        url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Wolfers%202006/wolfers2006_didtextbook.dta"
        tmp = Downloads.download(url)
        RCall.@rput tmp
        RCall.rcopy(R"data = haven::read_dta(tmp)")
        data = RCall.rcopy(R"data")

        data_julia = Dict(
            :data                   => data,
            
            :Y                      => "div_rate",
            :G                      => "state",
            :T                      => "year",
            :D                      => "rel_time1",
            :D0                     => nothing,

            :type                   => "feTR",

            :controls               => ["rel_timeminus$(i)" for i in 1:9],
            :weights                => data[!, :stpop],
            :other_treatments       => ["rel_time$(i)" for i in 2:16],
            :test_random_weights    => "year",
            
            :summary_measures       => true,
            :path                   => nothing,
        )

        RCall.rcopy(R"
            data_R = list(
                data                   = data,
                
                Y                      = 'div_rate',
                G                      = 'state',
                T                      = 'year',
                D                      = 'rel_time1',
                D0                     = NULL,

                type                   = 'feTR',
                
                controls               = paste0('rel_timeminus', 1:9),
                weights                = data$'stpop',
                other_treatments       = paste0('rel_time', 2:16),
                test_random_weights    = 'year',
                
                summary_measures       = TRUE,
                path                   = NULL
            )
        ")
        data_R = RCall.rcopy(R"data_R")

        data_R, data_julia = test_step_1_renaming(data_R, data_julia);
        data_R, data_julia = test_step_2_transform(data_R, data_julia);
        data_R, data_julia = test_step_3_filter(data_R, data_julia);
        data_R, data_julia = test_step_4_calculate(data_R, data_julia);
        data_R, data_julia = test_step_5_result(data_R, data_julia);
    end
end;
stepwise_test_1();