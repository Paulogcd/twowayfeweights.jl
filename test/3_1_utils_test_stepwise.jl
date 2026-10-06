using JLD2
using OrderedCollections

function save_test_data(data_R::OrderedCollections.OrderedDict, data_julia::Dict, step::String)
    RCall.@rput data_R
    RCall.@rput step
    test_directory = @__DIR__
    RCall.@rput test_directory
    RCall.rcopy(R"
        base::saveRDS(
            object = data_R,
            file = file.path(test_directory, \"data\", \"output\", paste0(\"data_R_\", step, \".rds\"))
        )")
    JLD2.@save joinpath(@__DIR__, "data", "output", string("data_julia_", step, ".jld2")) data_julia;
end

function test_step_1_renaming(data_R, data_julia, save = false)

     Test.@testset "Step 1: renaming" begin
        RCall.@rput data_R
        
        Y                 = data_julia[:Y]
        G                 = data_julia[:G]
        T                 = data_julia[:T]
        D                 = data_julia[:D]
        D0                = data_julia[:D0]
        
        #Julia:
        for v in filter(!isnothing, [Y, G, T, D, D0])
            if !(typeof(data_julia[:data][!, Symbol(v)]) <: AbstractVector{T} where {T <: Union{Missing, Real}})
                data_julia[:data][!, Symbol(v)] .= TwoWayFEWeights.parse_float_or_missing.(data_julia[:data][!, Symbol(v)])
            end
        end
        
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
                if (!inherits(data_R$data[[v]], \"numeric\")){
                    data_R$data[[v]] <- as.numeric(data_R$data[[v]])
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
            data_R[:controls_rename] = nothing
        end
        if :treatments_rename ∉ keys(data_R)
            data_R[:treatments_rename] = nothing
        end
        if :random_weight_rename ∉ keys(data_R)
            data_R[:random_weight_rename] = nothing
        end
        data_R = RCall.@rput data_R

        # This is not enough to work due to local binding.
        # We return the value at the end of the function.

        if save save_test_data(data_R, data_julia, "1") end

        Test.@test length(data_R) == length(data_julia)
        Test.@test size(data_R[:data_renamed]) == size(data_julia[:data_renamed])
        result = isequal(
            data_julia[:data_renamed],
            RCall.rcopy(R"data_R$data_renamed")
        )
        if !result
            for col_name in string.(names(data_julia[:data_renamed]))
                RCall.@rput col_name
                julia_test = data_julia[:data_renamed][!, Symbol(col_name)] |> skipmissing |> collect
                R_test = RCall.rcopy(R"data_R$data_renamed[[col_name]]") |> skipmissing |> collect
                result_approx = isapprox(
                    julia_test,
                    R_test,
                    atol = 1e-4
                )
                if !result_approx
                    @show col_name
                    @show eltype(julia_test)
                    @show eltype(R_test)
                    @show length(julia_test)
                    @show length(R_test)
                    @show maximum(abs.(julia_test .- R_test))
                end
                Test.@test result_approx
            end
        else
            Test.@test result
        end
    end;

    return(data_R, data_julia)

end

function test_step_2_transform(data_R, data_julia, save = false)

    Test.@testset "Step 2: transforming" begin
    
        RCall.@rput data_R

        # Julia: 
        data_julia[:data_transformed] = TwoWayFEWeights.twowayfeweights_transform(
            df          = data_julia[:data_renamed],
            controls    = data_julia[:controls_rename],
            weights     = data_julia[:weights],
            treatments  = data_julia[:treatments_rename])
        
        # Takes 7 minutes to run.
        RCall.rcopy(R"
            data_R$\"data_transformed\" = TwoWayFEWeights:::twowayfeweights_transform(
                data_R$\"data_renamed\",
                data_R$\"controls_rename\",
                data_R$\"weights\",
                data_R$\"treatments_rename\")
        ")
        data_R = RCall.rcopy(R"data_R")
        RCall.rcopy(R"data_R$data_transformed")

        if save save_test_data(data_R, data_julia, "2") end
        
        # Here, we have to adapt.
        # The numbers are the same, but the type imply that the test will always fail.
        # Therefore, we only take the first 4 characters.
        # This is not very robust and should be improved.
        # What if the time units have more or less than 4 characters?
        # data_julia_for_test = first.(string.(data_julia[:data_transformed][!, "Tfactor"]), 4)
        corrected_values = string.(data_julia[:data_transformed][!, "Tfactor"])
        corrected_values = [split.(corrected_values, ".")[i][1] for i in 1:length(corrected_values)]

        @test corrected_values == RCall.rcopy(R"data_R$data_transformed |> dplyr::pull(Tfactor)")
        Test.@test length(data_R) == length(data_julia)

        result = isequal(
            data_julia[:data_transformed][:, DataFrames.Not(:Tfactor)],
            RCall.rcopy(R"data_R$data_transformed |> dplyr::select(- Tfactor)")
        )
        if !result
            for col_name in string.(names(data_julia[:data_transformed][:, DataFrames.Not(:Tfactor)]))
                RCall.@rput col_name
                julia_test = data_julia[:data_transformed][!, Symbol(col_name)] |> skipmissing |> collect
                R_test = RCall.rcopy(R"data_R$data_transformed[[col_name]]") |> skipmissing |> collect
                result_approx = isapprox(
                    julia_test,
                    R_test,
                    atol = 1e-4
                )
                if !result_approx
                    @show col_name
                    @show eltype(julia_test)
                    @show eltype(R_test)
                    @show length(julia_test)
                    @show length(R_test)
                    @show maximum(abs.(julia_test .- R_test))
                end
                Test.@test result_approx
            end
        else
            Test.@test result
        end
    end

    return(data_R, data_julia)
end


function test_step_3_filter(data_R, data_julia, save = false)

     Test.@testset "Step 3: filtering" begin    
        
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

        if save save_test_data(data_R, data_julia, "3") end

        result = isequal(
            data_julia[:data_filtered][:, DataFrames.Not(:Tfactor)],
            RCall.rcopy(R"data_R$data_filtered |> dplyr::select(- Tfactor)")
        )
        if !result
            # Extra steps for GitHub test pipeline.
            for col_name in string.(names(data_julia[:data_filtered][:, DataFrames.Not(:Tfactor)]))
                RCall.@rput col_name
                julia_test = data_julia[:data_filtered][!, Symbol(col_name)] |> skipmissing |> collect
                R_test = RCall.rcopy(R"data_R$data_filtered[[col_name]]") |> skipmissing |> collect
                result_approx = isapprox(
                    julia_test,
                    R_test,
                    atol = 1e-4
                )
                if !result_approx
                    @show col_name
                    @show eltype(julia_test)
                    @show eltype(R_test)
                    @show length(julia_test)
                    @show length(R_test)
                    @show maximum(abs.(julia_test .- R_test))
                end
                Test.@test result_approx
            end
        else
            Test.@test result
        end
        Test.@test length(data_R) == length(data_julia)
    end;

    return(data_R, data_julia)

end

function test_step_4_calculate(data_R, data_julia, save = false)
    
     Test.@testset "Step 4: calculate" begin
        
        RCall.@rput data_R

        data_julia[:res] = TwoWayFEWeights.twowayfeweights_calculate(
            dat        = data_julia[:data_filtered],
            type       = data_julia[:type],
            controls   = data_julia[:controls_rename],
            treatments = data_julia[:treatments_rename],
            method     = method
        )

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

        if save save_test_data(data_R, data_julia, "4") end

        for col_name in names(data_julia[:res][:dat][:, DataFrames.Not(:Tfactor)])
            RCall.@rput col_name
            result = isequal(
                data_julia[:res][:dat][!, col_name],
                RCall.rcopy(R"data_R$res$dat |> dplyr::pull(col_name)")
            )
            if !result # If the column contains missing values, it will pass the isequal test, but fail the isapprox one.
                julia_test = data_julia[:res][:dat][!, col_name]
                R_test = RCall.rcopy(R"data_R$res$dat |> dplyr::pull(col_name)")
                result_approx = isapprox(
                    julia_test,
                    R_test;
                    atol = 1e-4
                )
                if !result_approx
                    @show col_name
                    @show eltype(julia_test)
                    @show eltype(R_test)
                    @show length(julia_test)
                    @show length(R_test)
                    @show maximum(abs.(julia_test .- R_test))
                end
                Test.@test result_approx
            else
                # print(col, " - ", result, " - ", result_approx, "\n")
                Test.@test result
            end
        end;
        Test.@test isapprox(
            data_julia[:res][:beta],
            RCall.rcopy(R"data_R$res$\"beta\""),
            atol = 1e-4)
        Test.@test length(data_R) == length(data_julia)
    end;

    return(data_R, data_julia)

end

function test_step_5_result(data_R, data_julia, save = false)

     Test.@testset "Step 5: results" begin

        RCall.@rput data_R

        data_julia[:result] = TwoWayFEWeights.twowayfeweights_result(
            dat             = data_julia[:res][:dat],
            beta            = data_julia[:res][:beta],
            random_weights  = data_julia[:random_weight_rename],
            treatments      = data_julia[:treatments_rename],
            method          = method
        )
        
        RCall.rcopy(R"
            data_R$result = TwoWayFEWeights:::twowayfeweights_result(
                dat            = data_R$res$dat,
                beta           = data_R$res$beta,
                random_weights = data_R$random_weight_rename,
                treatments     = data_R$treatments_rename
            )
        ")

        data_R = RCall.rcopy(R"data_R")

        if save save_test_data(data_R, data_julia, "5") end

        Test.@test length(data_R) == length(data_julia)
        Test.@test isapprox(
            data_julia[:result][:beta],
            RCall.rcopy(R"data_R$result$\"beta\""),
            atol = 1e-4
        )

        for k in string.(keys(data_julia[:result]))
            RCall.@rput k
            if data_julia[:result][Symbol(k)] isa OrderedCollections.OrderedDict
                for kk in string.(keys(data_julia[:result][Symbol(k)]))
                    RCall.@rput kk
                    julia_test = data_julia[:result][Symbol(k)][Symbol(kk)]
                    R_test = RCall.rcopy(R"data_R$result[[k]][[kk]]")
                    result = isequal(
                        julia_test,
                        R_test
                    )
                    if !result
                        result_approx = isapprox(
                            julia_test,
                            R_test;
                            atol = 1e-4
                        )
                        if !result_approx
                            @show col_name
                            @show eltype(julia_test)
                            @show eltype(R_test)
                            @show length(julia_test)
                            @show length(R_test)
                            @show maximum(abs.(julia_test .- R_test))
                        end
                        # print(k, " - ", kk, " - ", result, " - ", result_approx, "\n")
                        Test.@test result_approx
                    else 
                        Test.@test result
                    end

                end
            elseif data_julia[:result][Symbol(k)] isa DataFrames.DataFrame
                obj = data_julia[:result][Symbol(k)]
                RCall.rcopy(R"obj <- data_R$result[[k]]")
                Test.@test names(obj) == RCall.rcopy(R"names(obj)")
                for col_names in names(obj)
                    RCall.@rput col_names
                    julia_test = obj[!, col_names]
                    R_test = RCall.rcopy(R"obj[[col_names]]")
                    result = isequal(
                        julia_test,
                        R_test
                    )
                    if !result
                        result_approx = isapprox(
                            length(julia_test) == 1  ? julia_test[1] : julia_test, # For 1-lined Dataframe.
                            R_test;
                            atol = 1e-3
                        )
                        if !result_approx
                            @show col_name
                            @show eltype(julia_test)
                            @show eltype(R_test)
                            @show length(julia_test)
                            @show length(R_test)
                            @show maximum(abs.(julia_test .- R_test))
                        end
                        # print(k, " - ", col_names, " - ", result, " - ", result_approx, "\n")
                        Test.@test result_approx
                    else
                        Test.@test result
                    end
                end
            else
                julia_test = data_julia[:result][Symbol(k)]
                R_test = RCall.rcopy(R"data_R$result[[k]]")
                result = isequal(
                    julia_test,
                    R_test
                )
                if !result
                    result_approx = isapprox(
                        julia_test,
                        R_test;
                        atol = 1e-4
                    )
                    if !result_approx
                        @show col_name
                        @show eltype(julia_test)
                        @show eltype(R_test)
                        @show length(julia_test)
                        @show length(R_test)
                        @show maximum(abs.(julia_test .- R_test))
                    end
                    # print(k, " - ", result, " - ", result_approx, "\n")
                    Test.@test result_approx
                else
                    Test.@test result
                end
            end
        end;
    end;

    return(data_R, data_julia)

end

function full_test_step_by_step(data_R, data_julia)

    RCall.@rput data_R

    data_R, data_julia = test_step_1_renaming(data_R,    data_julia);
    data_R, data_julia = test_step_2_transform(data_R,   data_julia);
    data_R, data_julia = test_step_3_filter(data_R,      data_julia);
    data_R, data_julia = test_step_4_calculate(data_R,   data_julia);
    data_R, data_julia = test_step_5_result(data_R,      data_julia);

end

