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

        if save save_test_data(data_R, data_julia, "1") end

        compare_R_julia(data_R, data_julia)
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
        julia_test = [split.(corrected_values, ".")[i][1] for i in 1:length(corrected_values)]
        R_test = RCall.rcopy(R"data_R$data_transformed |> dplyr::pull(Tfactor)")
        Test.@test julia_test == R_test

        compare_R_julia(data_R[:data_transformed], data_julia[:data_transformed])
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

        compare_R_julia(data_R[:data_filtered][:, DataFrames.Not(:Tfactor)], data_julia[:data_filtered][:, DataFrames.Not(:Tfactor)])
    end

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

        compare_R_julia(data_R[:res], data_julia[:res])
    
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

        # data_julia[:result]
        # RCall.rcopy(R"data_R$result")

        data_R = RCall.rcopy(R"data_R")

        if save save_test_data(data_R, data_julia, "5") end

        compare_R_julia(data_R[:result], data_julia[:result])

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

function compare_R_julia(R_object::AbstractDict, julia_object::AbstractDict)
    
    # R_object = data_R[:result]
    # julia_object = data_julia[:result]
    
    RCall.@rput R_object

    # General tests
    Test.@test length(R_object) == length(julia_object)
    Test.@test keys(R_object) == keys(julia_object)

    for k in string.(keys(julia_object))
        
        RCall.@rput k

        julia_object_k  = julia_object[Symbol(k)]
        R_object_k      = RCall.rcopy(R"R_object[[k]]")

        RCall.@rput R_object_k

        if julia_object_k isa OrderedCollections.OrderedDict

            # @info string("The object ", k, " is a Dict.")
            compare_R_julia_object(R_object_k, julia_object_k)

        elseif julia_object_k isa DataFrames.DataFrame
            
            # @info string("The object ", k, " is a DataFrame.")
            compare_R_julia(R_object_k, julia_object_k)
        
        else

            result = isequal(R_object_k, julia_object_k)
            
            if !result

                result_approx = isapprox(
                    R_object_k,
                    julia_object_k;
                    atol = 1e-4
                )

                if !result_approx
                    @show k
                    @show eltype(julia_object_k)
                    @show eltype(R_object_k)
                    @show length(julia_object_k)
                    @show length(R_object_k)
                    @show maximum(abs.(julia_object_k .- R_object_k))
                end
                Test.@test result_approx
            else
                Test.@test result
            end
        end
    end
end

function compare_R_julia(R_object_k::DataFrames.DataFrame, julia_object_k::DataFrames.DataFrame)
    
    RCall.@rput R_object_k
    Test.@test size(julia_object_k) == size(R_object_k)
    Test.@test length(setdiff(names(julia_object_k), names(R_object_k))) == 0

    # For Tfactor:
    if "Tfactor" ∈ names(julia_object_k)
        julia_object_k = julia_object_k[:, DataFrames.Not(:Tfactor)]
        R_object_k = R_object_k[:, DataFrames.Not(:Tfactor)]
    end

    for col_name in names(julia_object_k)

        RCall.@rput col_name
        
        julia_test = julia_object_k[!, col_name]
        julia_test = length(julia_test) == 1  ? julia_test[1] : julia_test
        R_test = RCall.rcopy(R"R_object_k[[col_name]]")

        result = isequal(R_test, julia_test)
        
        if !result
            
            julia_test  = julia_test |> skipmissing |> collect
            R_test      = R_test |> skipmissing |> collect

            result_approx = isapprox(
                julia_test,
                R_test;
                atol = 1e-2
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
            Test.@test result
        end
    end
end

function compare_R_julia_object(R_object_k, julia_object_k)

    if R_object_k isa DataFrames.DataFrame && julia_object_k isa DataFrames.DataFrame
        
        compare_R_julia(R_object_k, julia_object_k)

    else
    
        R_kk = copy(R_object_k)
        RCall.@rput R_kk
        Test.@test length(julia_object_k) == length(R_kk)
        Test.@test length(setdiff(keys(julia_object_k), keys(R_kk))) == 0

        for k_rec in string.(keys(julia_object_k))

            RCall.@rput k_rec
            
            julia_test = julia_object_k[Symbol(k_rec)]
            julia_test = length(julia_test) == 1  ? julia_test[1] : julia_test
            R_test = RCall.rcopy(R"R_kk[[k_rec]]")

            result = isequal(R_test, julia_test)
            
            if !result
                
                julia_test  = julia_test |> skipmissing |> collect
                R_test      = R_test |> skipmissing |> collect

                result_approx = isapprox(
                    julia_test,
                    R_test;
                    atol = 1e-2
                )
                if !result_approx
                    @show k_rec
                    @show eltype(julia_test)
                    @show eltype(R_test)
                    @show length(julia_test)
                    @show length(R_test)
                    @show maximum(abs.(julia_test .- R_test))
                end
                Test.@test result_approx
            else
                Test.@test result
            end
        end
    end
end