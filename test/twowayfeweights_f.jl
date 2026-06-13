@testset "twowayfeweights" begin

    using ReadStatTables

    # For this test, we are going to use the official / original 
    # code snipped used in the original package.
    repo = "chaisemartinPackages/twowayfeweights/main"
    file = "wagepan_twfeweights.dta"
    url = "https://raw.githubusercontent.com" * "/" * repo * "/" * file
    path = download(url)
    wagepan = ReadStatTables.readstat(path)
    wagepan = DataFrames.DataFrame(wagepan)
    RCall.@rput wagepan

    @testset "feTR" begin
        julia_resultat = twowayfeweights(
            data                = wagepan,
            Y                   = "lwage",
            G                   = "nr",
            T                   = "year",
            D                   = "union",
            type                = "feTR",
            summary_measures    = true,
            test_random_weights = "educ")

        R_resultat = RCall.rcopy(R"TwoWayFEWeights::twowayfeweights(
            wagepan,                        # input data
            'lwage', # Y
            'nr', # G
            'year', # T
            'union', # D
            type                = 'feTR', 
            summary_measures    = TRUE,   
            test_random_weights = 'educ'  
        )")
        
        Test.@test julia_resultat[:nr_minus]            == R_resultat[:nr_minus]
        Test.@test julia_resultat[:nr_weights]          == R_resultat[:nr_weights]
        Test.@test isapprox(julia_resultat[:sum_plus]             , R_resultat[:sum_plus], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:sum_minus]            , R_resultat[:sum_minus], atol = 0.0001)
        Test.@test julia_resultat[:dat_result].T          == R_resultat[:dat_result].T
        Test.@test julia_resultat[:dat_result].G          == R_resultat[:dat_result].G
        Test.@test isapprox(julia_resultat[:dat_result].weight     , R_resultat[:dat_result].weight, atol = 0.0001)
        Test.@test isapprox(julia_resultat[:beta]                  , R_resultat[:beta], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:sensibility]                    , R_resultat[:sensibility], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:mat]                     , R_resultat[:mat], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:sensibility2]         , R_resultat[:sensibility2], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:tot_cells]           , R_resultat[:tot_cells], atol = 1)
        Test.@test julia_resultat[:type]                == R_resultat[:type]
        Test.@test julia_resultat[:params]              == R_resultat[:params]
        Test.@test julia_resultat[:summary_measures]    == R_resultat[:summary_measures]
        Test.@test julia_resultat[:random_weights]      == R_resultat[:random_weights]
    end


    @testset "feS" begin 
        
        julia_resultat = twowayfeweights(
            data = wagepan,
            Y = "lwage",
            G = "nr",
            T = "year",
            D = "union",
            type = "feS",
            summary_measures = true,
            test_random_weights = "educ")
        
        R_resultat = RCall.rcopy(R"TwoWayFEWeights::twowayfeweights(
            wagepan,                        # input data
            'lwage', # Y
            'nr', # G
            'year', # T
            'union', # D
            type                = 'feS', 
            summary_measures    = TRUE,   
            test_random_weights = 'educ'  
        )")

        Test.@test julia_resultat[:nr_minus]            == R_resultat[:nr_minus]
        Test.@test julia_resultat[:nr_weights]          == R_resultat[:nr_weights]
        Test.@test isapprox(julia_resultat[:sum_plus]             , R_resultat[:sum_plus], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:sum_minus]            , R_resultat[:sum_minus], atol = 0.0001)
        Test.@test julia_resultat[:dat_result].T          == R_resultat[:dat_result].T
        Test.@test julia_resultat[:dat_result].G          == R_resultat[:dat_result].G
        Test.@test isapprox(julia_resultat[:dat_result].weight     , R_resultat[:dat_result].weight, atol = 0.0001)
        Test.@test isapprox(julia_resultat[:beta]                  , R_resultat[:beta], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:sensibility]                    , R_resultat[:sensibility], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:mat]                     , R_resultat[:mat], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:tot_cells]           , R_resultat[:tot_cells], atol = 1)
        Test.@test julia_resultat[:type]                == R_resultat[:type]
        Test.@test julia_resultat[:params]              == R_resultat[:params]
        Test.@test julia_resultat[:summary_measures]    == R_resultat[:summary_measures]
        Test.@test julia_resultat[:random_weights]      == R_resultat[:random_weights]
    
    end

    @testset "fdTR" begin
        
        julia_resultat = twowayfeweights(
                data = wagepan,
                Y = "diff_lwage",
                G = "nr",
                T = "year",
                D = "diff_union", # use differenced versions of Y and D
                type                = "fdTR",             # changed
                D0                  = "union",            # added (req'd arg for fdTR type)
                summary_measures    = true,
                test_random_weights = "educ")

        R_resultat = RCall.rcopy(R"TwoWayFEWeights::twowayfeweights(
                wagepan,                        # input data
                'diff_lwage', # Y
                'nr', # G
                'year', # T
                'diff_union', # D
                type                = 'fdTR', 
                D0 = 'union',
                summary_measures    = TRUE,   
                test_random_weights = 'educ'  
            )")

        Test.@test julia_resultat[:nr_minus]            == R_resultat[:nr_minus]
        Test.@test julia_resultat[:nr_weights]          == R_resultat[:nr_weights]
        Test.@test isapprox(julia_resultat[:sum_plus]             , R_resultat[:sum_plus], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:sum_minus]            , R_resultat[:sum_minus], atol = 0.0001)
        Test.@test julia_resultat[:dat_result].T          == R_resultat[:dat_result].T
        Test.@test julia_resultat[:dat_result].G          == R_resultat[:dat_result].G
        Test.@test isapprox(julia_resultat[:dat_result].weight     , R_resultat[:dat_result].weight, atol = 0.0001)
        Test.@test isapprox(julia_resultat[:beta]                  , R_resultat[:beta], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:sensibility]                    , R_resultat[:sensibility], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:mat]                     , R_resultat[:mat], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:tot_cells]           , R_resultat[:tot_cells], atol = 1)
        Test.@test julia_resultat[:type]                == R_resultat[:type]
        Test.@test julia_resultat[:params]              == R_resultat[:params]
        Test.@test julia_resultat[:summary_measures]    == R_resultat[:summary_measures]
        Test.@test julia_resultat[:random_weights]      == R_resultat[:random_weights]
    end

    @testset "fdS" begin
        
        julia_resultat = twowayfeweights(
            data                = wagepan,
            Y                   = "diff_lwage",
            G                   = "nr",
            T                   = "year",
            D                   = "diff_union",
            type                = "fdS",  
            D0                  = "union",
            summary_measures    = true,
            test_random_weights = "educ")


        R_resultat = RCall.rcopy(R"TwoWayFEWeights::twowayfeweights(
                wagepan,                        # input data
                'diff_lwage', # Y
                'nr', # G
                'year', # T
                'diff_union', # D
                type                = 'fdS', 
                D0 = 'union',
                summary_measures    = TRUE,   
                test_random_weights = 'educ'  
            )")

        Test.@test julia_resultat[:nr_minus]            == R_resultat[:nr_minus]
        Test.@test julia_resultat[:nr_weights]          == R_resultat[:nr_weights]
        Test.@test isapprox(julia_resultat[:sum_plus]             , R_resultat[:sum_plus], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:sum_minus]            , R_resultat[:sum_minus], atol = 0.0001)
        Test.@test julia_resultat[:dat_result].T          == R_resultat[:dat_result].T
        Test.@test julia_resultat[:dat_result].G          == R_resultat[:dat_result].G
        Test.@test isapprox(julia_resultat[:dat_result].weight     , R_resultat[:dat_result].weight, atol = 0.0001)
        Test.@test isapprox(julia_resultat[:beta]                  , R_resultat[:beta], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:sensibility]                    , R_resultat[:sensibility], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:mat]                     , R_resultat[:mat], atol = 0.0001)
        Test.@test isapprox(julia_resultat[:tot_cells]           , R_resultat[:tot_cells], atol = 1)
        Test.@test julia_resultat[:type]                == R_resultat[:type]
        Test.@test julia_resultat[:params]              == R_resultat[:params]
        Test.@test julia_resultat[:summary_measures]    == R_resultat[:summary_measures]
        Test.@test julia_resultat[:random_weights]      == R_resultat[:random_weights]
    end

end;