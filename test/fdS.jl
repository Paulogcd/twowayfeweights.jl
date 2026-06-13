# Step by step test functions for type == "fdS"
Test.@testset "fdS" begin

    using ReadStatTables

    ## Initialisation 
    begin
        ## Julia
        repo = "chaisemartinPackages/twowayfeweights/main"
        file = "wagepan_twfeweights.dta"
        url = "https://raw.githubusercontent.com" * "/" * repo * "/" * file
        path = download(url)
        wagepan = ReadStatTables.readstat(path)
        wagepan = DataFrames.DataFrame(wagepan)

        data                = wagepan
        Y                   = "diff_lwage"
        G                   = "nr"
        T                   = "year"
        D                   = "diff_union"
        type                = "fdS"
        D0                  = "union"
        summary_measures    = true
        test_random_weights = "educ"
        controls            = nothing
        weights             = nothing
        other_treatments    = nothing
        path                = nothing

        ## R
        RCall.@rput wagepan
        RCall.@rput data
        RCall.@rput Y
        RCall.@rput G
        RCall.@rput T
        RCall.@rput D
        RCall.@rput type
        RCall.@rput D0
        RCall.@rput summary_measures
        RCall.@rput test_random_weights
        RCall.@rput controls
        RCall.@rput weights
        RCall.@rput other_treatments
        RCall.@rput path

        ## Julia
        controls_rename         = get_controls_rename(controls)
        treatments_rename       = get_treatments_rename(other_treatments)
        random_weight_rename    = get_random_weight_rename(test_random_weights)

        ## R
        RCall.rcopy(R"controls_rename = TwoWayFEWeights:::get_controls_rename(controls)")
        RCall.rcopy(R"treatments_rename = TwoWayFEWeights:::get_treatments_rename(other_treatments)")
        RCall.rcopy(R"random_weight_rename = TwoWayFEWeights:::get_random_weight_rename(test_random_weights)")

        ## TEST
        @test isequal(controls_rename, RCall.rcopy(R"controls_rename"))
        @test isequal(treatments_rename, RCall.rcopy(R"treatments_rename"))
        @test isequal(random_weight_rename, RCall.rcopy(R"random_weight_rename"))
    end

    ## Renaming
    begin
        # Julia
        data_renamed = twowayfeweights_rename_var(
            df = data,
            Y = Y,
            G = G,
            T = T,
            D = D,
            D0 = D0,
            controls = controls,
            treatments = other_treatments,
            random_weights = test_random_weights)

        ## R
        RCall.rcopy(R"data_renamed = TwoWayFEWeights:::twowayfeweights_rename_var(df = data, Y, G, T, D, D0, controls, other_treatments, test_random_weights)")

        # TEST
        @test isequal(data_renamed, RCall.rcopy(R"data_renamed"))
    end

    ## Transformation
    begin
        RCall.rcopy(R"data_transformed    = TwoWayFEWeights:::twowayfeweights_transform(data_renamed, controls_rename, weights, treatments_rename)")

        data_transformed = twowayfeweights_transform(
            df          = data_renamed,
            controls    = controls_rename,
            weights     = weights,
            treatments  = test_random_weights)


        # TEST
        @test isequal(data_transformed.Y, RCall.rcopy(R"data_transformed$Y")) # OK 
        @test isequal(data_transformed.G, RCall.rcopy(R"data_transformed$G")) # OK 
        @test isequal(data_transformed.T, RCall.rcopy(R"data_transformed$T")) # OK 
        @test isequal(data_transformed.D, RCall.rcopy(R"data_transformed$D")) # OK 
        @test isequal(data_transformed.D0, RCall.rcopy(R"data_transformed$D0")) # OK 
        @test isequal(data_transformed.RW_educ, RCall.rcopy(R"data_transformed$RW_educ")) # OK 
        @test isequal(data_transformed.weights, RCall.rcopy(R"data_transformed$weights")) # OK 

        @test isequal(
            Float64.(collect(unwrap.(data_transformed.Tfactor))),
            parse.(Float64, collect(unwrap.(RCall.rcopy(R"data_transformed$Tfactor"))))
        )

        @test isequal(data_transformed.TFactorNum, RCall.rcopy(R"data_transformed$TFactorNum")) # FAIL
    end
end

## Filtrage
begin
    
    # Julia
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
    
    # R
    RCall.rcopy(R"data_filtered       = TwoWayFEWeights:::twowayfeweights_filter(data_transformed, Y, G, T, D, D0, type, controls_rename, treatments_rename)")

    RCall.rcopy(R"print(data_filtered)")

    @test isequal(data_filtered, RCall.rcopy(R"data_filtered"))

    @test isequal(data_filtered.Y, RCall.rcopy(R"data_filtered$Y")) # OK 
    @test isequal(data_filtered.G, RCall.rcopy(R"data_filtered$G")) # OK 
    @test isequal(data_filtered.T, RCall.rcopy(R"data_filtered$T")) # OK 
    @test isequal(data_filtered.D, RCall.rcopy(R"data_filtered$D")) # OK 
    @test isequal(data_filtered.D0, RCall.rcopy(R"data_filtered$D0")) # OK 
    @test isequal(data_filtered.RW_educ, RCall.rcopy(R"data_filtered$RW_educ")) # OK 
    @test isequal(data_filtered.weights, RCall.rcopy(R"data_filtered$weights")) # OK 

    @test isequal(
        Float64.(collect(unwrap.(data_filtered.Tfactor))),
        parse.(Float64, collect(unwrap.(RCall.rcopy(R"data_filtered$Tfactor"))))
    )

    @test isequal(data_filtered.TFactorNum, RCall.rcopy(R"data_filtered$TFactorNum")) # OK 

end

## Calculate
begin
    # This.
    
    # Julia
    resultat = twowayfeweights_calculate(
        dat = data_filtered,
        type = type,
        controls = controls_rename,
        treatments = treatments_rename)
    
    # R
    RCall.rcopy(R"resultat = TwoWayFEWeights:::twowayfeweights_calculate(
        dat        = data_filtered,
        type       = type,
        controls   = controls_rename,
        treatments = treatments_rename)")

    #
    dat_regression = data_filtered[data_filtered[:, :weights] .!= 0, :]
    RCall.rcopy(R"dat_regression = subset(data_filtered, weights != 0)")

    @test isequal(dat_regression, RCall.rcopy(R"dat_regression"))
    
    @test isequal(dat_regression.Y, RCall.rcopy(R"dat_regression$Y"))
    @test isequal(dat_regression.G, RCall.rcopy(R"dat_regression$G"))
    @test isequal(dat_regression.T, RCall.rcopy(R"dat_regression$T"))
    @test isequal(dat_regression.D, RCall.rcopy(R"dat_regression$D"))
    @test isequal(dat_regression.D0, RCall.rcopy(R"dat_regression$D0"))
    @test isequal(dat_regression.RW_educ, RCall.rcopy(R"dat_regression$RW_educ"))
    @test isequal(dat_regression.weights, RCall.rcopy(R"dat_regression$weights"))
    @test isequal(string.(Int64.(unwrap.(dat_regression.Tfactor))), RCall.rcopy(R"dat_regression$Tfactor"))
    
    # So the data is the same.

    # And the regression seems to yield the same result.

    @test resultat[:beta]           ≈ RCall.rcopy(R"resultat$beta") # Not the exact same value.
    @test resultat[:dat].Y          == RCall.rcopy(R"resultat$dat$Y") # OK 
    @test resultat[:dat].G          == RCall.rcopy(R"resultat$dat$G") # OK 
    @test resultat[:dat].T          == RCall.rcopy(R"resultat$dat$T") # OK 
    @test resultat[:dat].D          == RCall.rcopy(R"resultat$dat$D") # OK 
    @test resultat[:dat].D0         == RCall.rcopy(R"resultat$dat$D0") # OK 
    @test resultat[:dat].RW_educ    == RCall.rcopy(R"resultat$dat$RW_educ") # OK 
    
    @test resultat[:dat].nat_weight ≈ RCall.rcopy(R"resultat$dat$nat_weight") # FAIL

    resultat[:dat].nat_weight[resultat[:dat].nat_weight .!= RCall.rcopy(R"resultat$dat$nat_weight")]
    
    @test resultat[:dat].W ≈ RCall.rcopy(R"resultat$dat$W") # FAIL
    @test resultat[:dat].weight_result == RCall.rcopy(R"resultat$dat$weight_result") # FAIL 

    # These fail, but they also do for other type specifications, so it should not hinder the final result.
    
end



# Result

res = twowayfeweights_result(
        dat            = resultat[:dat],
        beta           = resultat[:beta],
        random_weights = random_weight_rename,
        treatments     = treatments_rename
    )

res_r = RCall.rcopy(R"TwoWayFEWeights:::twowayfeweights_result(
    dat             = resultat$dat,
    beta            = resultat$beta,
    random_weights  = random_weight_rename,
    treatments      = treatments_rename
)")

keys(res_r)

isequal(res[:nr_plus], res_r[:nr_plus])
isequal(res[:nr_minus], res_r[:nr_minus])
isequal(res[:nr_weights], res_r[:nr_weights])
isequal(res[:sum_plus], res_r[:sum_plus]) # FALSE
isequal(res[:sum_minus], res_r[:sum_minus])
isequal(res[:dat_result], res_r[:dat_result]) # FALSE
isequal(res[:beta], res_r[:beta]) # FALSE
isequal(res[:sensibility], res_r[:sensibility]) # FALSE
isequal(res[:mat], res_r[:mat]) # FALSE
isequal(res[:tot_cells], res_r[:tot_cells])

# Here, the problem seems to come from the weights, that amplify the rounding error between the two languages.