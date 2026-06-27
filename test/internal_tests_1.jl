Test.@testset "Internal_test_1" begin

    @info("1st internal test.")

    using ReadStatTables
    using Downloads
    using DataFrames

    # Sanity check
    Test.@testset "Initialisation" begin

        @info("Testing setup...")
        
        # Julia
        url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Wolfers%202006/wolfers2006_didtextbook.dta"
        tmp = Downloads.download(url)
        data = ReadStatTables.readstat(tmp)
        data = DataFrames.DataFrame(data)

        # R
        RCall.@rput url
        RCall.rcopy(R"data = haven::read_dta(url)")

        # Julia:
        other_treatments = [
            "rel_time2",
            "rel_time3",
            "rel_time4",
            "rel_time5",
            "rel_time6",
            "rel_time7",
            "rel_time8",
            "rel_time9",
            "rel_time10",
            "rel_time11",
            "rel_time12",
            "rel_time13",
            "rel_time14",
            "rel_time15",
            "rel_time16"
        ]

        controls = [
            "rel_timeminus1", 
            "rel_timeminus2", 
            "rel_timeminus3", 
            "rel_timeminus4", 
            "rel_timeminus5", 
            "rel_timeminus6", 
            "rel_timeminus7", 
            "rel_timeminus8", 
            "rel_timeminus9"
        ]

        Y       = "div_rate"
        G       = "state"
        T       = "year"
        D       = "rel_time1"
        D0      = nothing
        summary_measures = true
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
        RCall.rcopy(R"controls = c(
            'rel_timeminus1', 
            'rel_timeminus2', 
            'rel_timeminus3', 
            'rel_timeminus4', 
            'rel_timeminus5', 
            'rel_timeminus6', 
            'rel_timeminus7', 
            'rel_timeminus8', 
            'rel_timeminus9')")
        RCall.rcopy(R"weights = data$stpop")
        RCall.rcopy(R"other_treatments = c(
            'rel_time2',
            'rel_time3',
            'rel_time4',
            'rel_time5',
            'rel_time6',
            'rel_time7',
            'rel_time8',
            'rel_time9',
            'rel_time10',
            'rel_time11',
            'rel_time12',
            'rel_time13',
            'rel_time14',
            'rel_time15',
            'rel_time16')")

        Test.@test Y                   == RCall.rcopy(R"Y                   ")
        Test.@test G                   == RCall.rcopy(R"G                   ")
        Test.@test T                   == RCall.rcopy(R"T                   ")
        Test.@test D                   == RCall.rcopy(R"D                   ")
        Test.@test type                == RCall.rcopy(R"type                ")
        Test.@test D0                  == RCall.rcopy(R"D0                  ")
        Test.@test summary_measures    == RCall.rcopy(R"summary_measures    ")
        Test.@test test_random_weights == RCall.rcopy(R"test_random_weights ")
        Test.@test controls            == RCall.rcopy(R"controls            ")
        Test.@test weights             == RCall.rcopy(R"weights             ")
        Test.@test other_treatments    == RCall.rcopy(R"other_treatments    ")
    end;

    ## I - Renaming:
    Test.@testset "Renaming" begin
        
        @info("Testing transform function...")

        # Julia
        controls_rename         = get_controls_rename(controls)
        treatments_rename       = get_treatments_rename(other_treatments)
        random_weight_rename    = get_random_weight_rename(test_random_weights)
        data_renamed            = twowayfeweights_rename_var(df = data, Y = Y, G = G, T = T, D = D, D0 = D0, controls = controls, treatments = other_treatments, random_weights = test_random_weights)

        # R
        RCall.rcopy(R"controls_rename           = TwoWayFEWeights:::get_controls_rename(controls)")
        RCall.rcopy(R"treatments_rename         = TwoWayFEWeights:::get_treatments_rename(other_treatments)")
        RCall.rcopy(R"random_weight_rename      = TwoWayFEWeights:::get_random_weight_rename(test_random_weights)")
        RCall.rcopy(R"data_renamed = TwoWayFEWeights:::twowayfeweights_rename_var(data, Y, G, T, D, D0, controls, other_treatments, test_random_weights)")

        # TEST
        Test.@test isequal(controls_rename,         RCall.rcopy(R"controls_rename"))
        Test.@test isequal(treatments_rename,       RCall.rcopy(R"treatments_rename"))
        Test.@test isequal(random_weight_rename,    RCall.rcopy(R"random_weight_rename"))
        Test.@test isequal(data_renamed ,           RCall.rcopy(R"data_renamed"))
    end;

    ## II - Transform
    Test.@testset "Transform" begin
    
        @info("Testing transform function...")

        # Julia
        data_transformed = twowayfeweights_transform(
            df          = data_renamed,
            controls    = controls_rename,
            weights     = weights,
            treatments  = treatments_rename)
        
        # R 
        RCall.rcopy(R"data_transformed = TwoWayFEWeights:::twowayfeweights_transform(data_renamed, controls_rename, weights, treatments_rename)")
        
        # test
        # @test isequal(data_transformed, RCall.rcopy(R"data_transformed")) # PROBLEM HERE
        
        for colonne in names(data_transformed)[names(data_transformed) .!= "Tfactor"]
            RCall.@rput colonne
            # @info(@test isequal(data_transformed[!, Symbol(colonne)], RCall.rcopy(R"data_transformed |> dplyr::pull(colonne)")))
            @test isequal(data_transformed[!, Symbol(colonne)], RCall.rcopy(R"data_transformed |> dplyr::pull(colonne)"))
        end
        # As for the Tfactor column, I am not sure on how to proceed.
        # The test will always fail, as using RCall seems to be converting the values to Integer, and then String, 
        # Which gives for example CategoricalArray{String,1,UInt32}: "1956"...
        # Meanwhile, the Julia code will give CategoricalArray{Float32,1,UInt32}: 1956.0f0...
        # A conversion to string in the transform function does not seem to answer this issue, 
        # as we may want to keep the CategoricalArray type.
        # Maybe someone could suggest a solution?
        # @test isapprox(string.(data_transformed[!, :Tfactor]), RCall.rcopy(R"data_transformed$Tfactor"))
    end;

    ## III - Filter
    Test.@testset "Filter" begin

        @info("Testing filter function...")

        ## Julia
        data_filtered = twowayfeweights_filter(
            df = data_transformed,
            Y = "Y",
            G = "G",
            T = "T",
            D = "D",
            D0 = "D0",
            cmd_type = type,
            controls = controls_rename,
            treatments = treatments_rename)

        ## R
        RCall.rcopy(R"
            data_filtered = 
                TwoWayFEWeights:::twowayfeweights_filter(
                    df = data_transformed, 
                    Y, G, T, D, D0, type, 
                    controls_rename, 
                    treatments_rename)")

        @test isequal(data_filtered, RCall.rcopy(R"data_filtered")) 
        for colonne in names(data_filtered)[names(data_transformed) .!= "Tfactor"]
            RCall.@rput colonne
            # @info(@test isequal(data_transformed[!, Symbol(colonne)], RCall.rcopy(R"data_transformed |> dplyr::pull(colonne)")))
            @test isequal(data_filtered[!, Symbol(colonne)], RCall.rcopy(R"data_filtered |> dplyr::pull(colonne)"))
        end
        # Same problem here.
        # @info(@test isequal(data_transformed[!, Symbol("Tfactor")], RCall.rcopy(R"data_transformed |> dplyr::pull('Tfactor')")))
    end;
    
    # IV - Calculate
    Test.@testset "Calculate" begin 
    
        @info("Testing calculate function...")

        ## Julia
        res = twowayfeweights_calculate(
            dat        = data_filtered,
            type       = type,
            controls   = controls_rename,
            treatments = treatments_rename)

        ## R
        RCall.rcopy(R"res = TwoWayFEWeights:::twowayfeweights_calculate(
            dat        = data_filtered,
            type       = type,
            controls   = controls_rename,
            treatments = treatments_rename
        )")

        ## Test
        
        # Dat
        dat_to_test = res[:dat]
        RCall.rcopy(R"dat_to_test <- res$dat")
        for idx in 1:length(names(dat_to_test))
            
            colonne = names(dat_to_test)[idx]
            RCall.@rput colonne
            
            # For categorical values
            if typeof(dat_to_test[!, Symbol(colonne)]) == LabeledVector{Int32, Vector{Int32}, Union{Char, Int32}}
                # @info(@test isequal(refarray(dat_to_test[!, Symbol(colonne)]), RCall.rcopy(R"dat_to_test |> dplyr::pull(colonne)")))
                Test.@test isequal(refarray(dat_to_test[!, Symbol(colonne)]), RCall.rcopy(R"dat_to_test |> dplyr::pull(colonne)"))
            elseif typeof(dat_to_test[!, Symbol(colonne)]) == CategoricalVector{Float32, UInt32, Float32, CategoricalValue{Float32, UInt32}, Union{}}
                # Test fails for the same reasons as previously.
                # @info(@test isapprox(dat_to_test[!, Symbol(colonne)], RCall.rcopy(R"dat_to_test |> dplyr::pull(colonne)")))
            else 
                # @info(@test isapprox(dat_to_test[!, Symbol(colonne)], RCall.rcopy(R"dat_to_test |> dplyr::pull(colonne)"), atol = 0.1))
                Test.@test isapprox(dat_to_test[!, Symbol(colonne)], RCall.rcopy(R"dat_to_test |> dplyr::pull(colonne)"), atol = 0.1)
            end
        
        end

        # Beta
        Test.@test isapprox(res[:beta], RCall.rcopy(R"res$beta"))
    end;

    # V - Result
    Test.@testset "Result" begin

        @info("Testing result function...")

        ## Julia
        res_final = twowayfeweights_result(
            dat            = res[:dat],
            beta           = res[:beta],
            random_weights = random_weight_rename,
            treatments     = treatments_rename)

        ## R
        RCall.rcopy(R"res_final = TwoWayFEWeights:::twowayfeweights_result(
            dat            = res$dat,
            beta           = res$beta,
            random_weights = random_weight_rename,
            treatments     = treatments_rename
        )")

        ## Test

        # Dat

        # beta

        # random_weight
        
        # treatments_rename
        Test.@test isequal(res_final[:nr_plus], RCall.rcopy(R"res_final$nr_plus"))
        Test.@test isequal(res_final[:nr_minus], RCall.rcopy(R"res_final$nr_minus"))
        Test.@test isequal(res_final[:nr_weights], RCall.rcopy(R"res_final$nr_weights"))
        Test.@test isequal(res_final[:sum_plus], RCall.rcopy(R"res_final$sum_plus"))
        Test.@test isequal(res_final[:sum_minus], RCall.rcopy(R"res_final$sum_minus"))
        Test.@test isequal(res_final[:tot_cells], RCall.rcopy(R"res_final$tot_cells"))
        Test.@test isapprox(res_final[:mat], RCall.rcopy(R"res_final$mat"))
        
        for idx in treatments
            RCall.@rput idx
            for kk in collect(keys(res_final[Symbol(idx)]))
                # kk = collect(keys(res_final[Symbol(idx)]))[1]
                kk_to_R = string(kk)
                RCall.@rput kk_to_R
                RCall.rcopy(R"kk_to_R")
                Test.@test isapprox(res_final[Symbol(idx)][Symbol(kk)], RCall.rcopy(R"res_final[[idx]][[kk_to_R]]"))
            end
        end

        Test.@test isapprox(res_final[:beta], RCall.rcopy(R"res_final$beta"))
        
        # Test.@test isequal(res_final[:dat_result], RCall.rcopy(R"res_final$dat_result"))
    end;
end;
    

url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Wolfers%202006/wolfers2006_didtextbook.dta"
tmp = Downloads.download(url)
data = ReadStatTables.readstat(tmp)
data = DataFrames.DataFrame(data)


other_treatments = [
    "rel_time2",
    "rel_time3",
    "rel_time4",
    "rel_time5",
    "rel_time6",
    "rel_time7",
    "rel_time8",
    "rel_time9",
    "rel_time10",
    "rel_time11",
    "rel_time12",
    "rel_time13",
    "rel_time14",
    "rel_time15",
    "rel_time16"
]

controls = [
    "rel_timeminus1", 
    "rel_timeminus2", 
    "rel_timeminus3", 
    "rel_timeminus4", 
    "rel_timeminus5", 
    "rel_timeminus6", 
    "rel_timeminus7", 
    "rel_timeminus8", 
    "rel_timeminus9"
]

Y       = "div_rate"
G       = "state"
T       = "year"
D       = "rel_time1"
D0      = nothing
summary_measures = true
type    = "feTR"
test_random_weights = "year"
weights             = data.stpop

test_1_stata = twowayfeweights(
    data                = data,
    Y                   = "div_rate",
    G                   = "state",
    T                   = "year",
    D                   = "rel_time1",
    type                = "feTR",
    test_random_weights = "year",
    weights             = data.stpop,
    other_treatments    = other_treatments,
    controls            = controls)

RCall.rcopy(R"test_1_stata = TwoWayFEWeights:::twowayfeweights(
    data                = data,
    Y                   = 'div_rate' ,
    G                   = 'state',
    T                   = 'year',
    D                   = 'rel_time1',
    type                = 'feTR',
    test_random_weights = 'year',
    weights             = data$stpop,
    other_treatments    = other_treatments,
    controls            = controls)")