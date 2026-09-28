function test_step_1_renaming(data_R, data_julia)

    RCall.@rput data_R
    
    #Julia:
    data_julia[:controls_rename]         = TwoWayFEWeights.get_controls_rename(data_julia[:controls])
    data_julia[:treatments_rename]       = TwoWayFEWeights.get_treatments_rename(data_julia[:other_treatments])
    data_julia[:random_weight_rename]    = TwoWayFEWeights.get_random_weight_rename(data_julia[:test_random_weights])
    data_julia[:data_renamed] = TwoWayFEWeights.twowayfeweights_rename_var(
      df                = data_julia[:data],
      Y                 = data_julia[:Y],
      G                 = data_julia[:G],
      T                 = data_julia[:T],
      D                 = data_julia[:D],
      D0                = data_julia[:D0],
      controls          = data_julia[:controls],
      treatments        = data_julia[:other_treatments],
      random_weights    = data_julia[:test_random_weights]
    )

    # R:
    RCall.rcopy(R"
        for (v in c(
            data_R$Y,
            data_R$G, 
            data_R$T, 
            data_R$D, 
            data_R$D0)) {
            if (!inherits(data[[v]], \"numeric\")){
                data_R[[v]] <- as.numeric(data[[v]])
            }
        }    
        data_R$\"controls_rename\" = TwoWayFEWeights:::get_controls_rename(data_R$\"controls\")
        data_R$\"treatments_rename\" = TwoWayFEWeights:::get_treatments_rename(data_R$\"other_treatments\")
        data_R$\"random_weight_rename\" = TwoWayFEWeights:::get_random_weight_rename(data_R$\"test_random_weights\")
        data_R$\"data_renamed\" = TwoWayFEWeights:::twowayfeweights_rename_var(
            data_R$\"data\",
            data_R$\"Y\",
            data_R$\"G\",
            data_R$\"T\",
            data_R$\"D\",
            data_R$\"D0\",
            data_R$\"controls\",
            data_R$\"other_treatments\",
            data_R$\"test_random_weights\")
    ")
    data_R = RCall.rcopy(R"data_R")
    if :controls_rename ∉ keys(data_R)
        # RCall.rcopy(R"data_R$controls_rename <- NULL")
        data_R[:controls_rename] = nothing
    end
    if :treatments_rename ∉ keys(data_R)
        # RCall.rcopy(R"data_R$treatments_rename <- NULL")
        data_R[:treatments_rename] = nothing
    end
    if :random_weight_rename ∉ keys(data_R)
        # RCall.rcopy(R"data_R$random_weight_rename <- NULL")
        data_R[:random_weight_rename] = nothing
    end
    data_R = RCall.@rput data_R
    # This is not enough to work due to local binding.
    # We return the value at the end of the function.

    @testset "Step 1: renaming" begin
        @test isequal(
            data_julia[:data_renamed],
            RCall.rcopy(R"data_R$data_renamed")
        )
    end

    JLD2.@save joinpath(@__DIR__, "data", "output", "data_R.jld2") data_R;
    JLD2.@save joinpath(@__DIR__, "data", "output", "data_julia.jld2") data_julia;

    return(data_R, data_julia)

end

function test_step_2_transform(data_R, data_julia)

    RCall.@rput data_R

    # Julia: 
    data_julia[:data_transformed] = TwoWayFEWeights.twowayfeweights_transform(
        df          = data_julia[:data_renamed],
        controls    = data_julia[:controls_rename],
        weights     = data_julia[:weights],
        treatments  = data_julia[:treatments_rename])
    
    RCall.rcopy(R"
        data_R$\"data_transformed\" = TwoWayFEWeights:::twowayfeweights_transform(
            data_R$\"data_renamed\",
            data_R$\"controls_rename\",
            data_R$\"weights\",
            data_R$\"treatments_rename\")
    ")
    data_R = RCall.rcopy(R"data_R")

    # Here, we have to adapt.
    # The numbers are the same, but the type imply that the test will always fail.
    data_julia_for_test = first.(string.(data_julia[:data_transformed][!, "Tfactor"]), 4)

    @testset "Step 2: transforming" begin
        @test isequal(data_julia[:data_transformed][:, Not(:Tfactor)], RCall.rcopy(R"data_R$data_transformed |> dplyr::select(- Tfactor)"))
        @test data_julia_for_test == RCall.rcopy(R"data_R$data_transformed |> dplyr::pull(Tfactor)")
    end

    JLD2.@save joinpath(@__DIR__, "data", "output", "data_R.jld2") data_R;
    JLD2.@save joinpath(@__DIR__, "data", "output", "data_julia.jld2") data_julia;

    return(data_R, data_julia)
end


function test_step_3_filter(data_R, data_julia)

    RCall.@rput data_R

    RCall.rcopy(R"
        data_R$\"data_filtered\" = TwoWayFEWeights:::twowayfeweights_filter(
            data_R$\"data_transformed\",
            data_R$\"Y\",
            data_R$\"G\",
            data_R$\"T\",
            data_R$\"D\",
            data_R$\"D0\",
            data_R$\"type\",
            data_R$\"controls_rename\",
            data_R$\"treatments_rename\"
        )"
    )
    data_R = RCall.rcopy(R"data_R")

    data_julia[:data_filtered] = TwoWayFEWeights.twowayfeweights_filter(
        df = data_julia[:data_transformed],
        Y = "Y",
        G = "G",
        T = "T",
        D = "D",
        D0 = "D0",
        cmd_type = data_julia[:type],
        controls = data_julia[:controls_rename],
        treatments = data_julia[:treatments_rename])

    @testset "Step 3: filtering" begin
        @test isequal(data_julia[:data_transformed][:, Not(:Tfactor)], RCall.rcopy(R"data_R$data_transformed |> dplyr::select(- Tfactor)"))
    end

    JLD2.@save joinpath(@__DIR__, "data", "output", "data_R.jld2") data_R;
    JLD2.@save joinpath(@__DIR__, "data", "output", "data_julia.jld2") data_julia;

    return(data_R, data_julia)

end

function test_step_4_calculate(data_R, data_julia)
    
    RCall.@rput data_R

    data_julia[:res] = TwoWayFEWeights.twowayfeweights_calculate(
      dat        = data_julia[:data_filtered],
      type       = data_julia[:type],
      controls   = data_julia[:controls_rename],
      treatments = data_julia[:treatments_rename])

    # Here, we have to adapt to convert the data into a data.table object.
    RCall.rcopy(R"
        data_R$\"data_filtered\" <- data.table::as.data.table(data_R$\"data_filtered\")
    ")
      
    RCall.rcopy(R"    
        data_R$\"res\" = TwoWayFEWeights:::twowayfeweights_calculate(
            dt          = data_R$\"data_filtered\",
            type        = data_R$\"type\",
            controls    = data_R$\"controls_rename\",
            treatments  = data_R$\"treatments_rename\"
        )
    ")
    data_R = RCall.rcopy(R"data_R")

    setdiff(names(data_julia[:res][:dat]), RCall.rcopy(R"colnames(data_R$res$dat)"))
    names_in_common = intersect(names(data_julia[:res][:dat]), names(data_R[:res][:dat]))
    RCall.@rput names_in_common

    @testset "Step 4: calculate" begin
        @test isequal(
            # data_julia[:res][:dat][!, Not([:Tfactor, :W, :weight_result])],
            data_julia[:res][:dat][!, names_in_common],
            RCall.rcopy(R"data_R$res$\"dat\" |> dplyr::select(names_in_common)")
        )
        compare_df(
            RCall.rcopy(R"data_R$res$\"dat\" |> dplyr::select( - c(\"Tfactor\", \"W\", \"weight_result\"))"),
            data_julia[:res][:dat][!, Not([:Tfactor, :W, :weight_result])]
        )
        @test isapprox(data_julia[:res][:beta], RCall.rcopy(R"data_R$res$\"beta\""))
    end

    JLD2.@save joinpath(@__DIR__, "data", "output", "data_R.jld2") data_R;
    JLD2.@save joinpath(@__DIR__, "data", "output", "data_julia.jld2") data_julia;

    return(data_R, data_julia)

end

function test_step_5_result(data_R, data_julia)

    RCall.@rput data_R

    data_julia[:res] = TwoWayFEWeights.twowayfeweights_result(
        dat             = data_julia[:res][:dat],
        beta            = data_julia[:res][:beta],
        random_weights  = data_julia[:random_weight_rename],
        treatments      = data_julia[:treatments_rename]
    )
    
    RCall.rcopy(R"
        data_R$res = TwoWayFEWeights:::twowayfeweights_result(
            dat            = data_R$res$dat,
            beta           = data_R$res$beta,
            random_weights = data_R$random_weight_rename,
            treatments     = data_R$treatments_rename
        )
    ")
    
    @testset "Step 5: results" begin
        @test isequal(
            data_julia[:res],
            RCall.rcopy(R"data_R$res")
        )
    end

    RCall.rcopy(R"
        base::saveRDS(
            object = data_R,
            file = file.path(getwd(), \"test\", \"data\", \"output\", \"data_R.rds\")
        )")
    JLD2.@save joinpath(@__DIR__, "data", "output", "data_julia.jld2") data_julia;

    return(data_R, data_julia)

end

function full_test_step_by_step(data_R, data_julia)

    RCall.@rput data_R

    test_step_1_renaming(data_R, data_julia);
    test_step_2_transform(data_R, data_julia);
    test_step_3_filter(data_R, data_julia);
    test_step_4_calculate(data_R, data_julia);
    test_step_5_result(data_R, data_julia);

end

