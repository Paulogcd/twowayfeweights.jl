function force_to_vector(x)
    if x isa AbstractVector{<:AbstractString}
        return x
    elseif x isa String
        return [x]
    end
end

"""

function twowayfeweights_transform(;
    df::DataFrames.DataFrame,
    controls::Union{String, Vector{String}},
    weights::Union{String, Vector{String}, Nothing},
    treatments::Union{String, Vector{String}, Nothing})

Internal function.

"""
function twowayfeweights_transform(;
    df::DataFrames.DataFrame,
    controls::Union{Nothing, String, AbstractVector{<:String}},
    weights::Union{Nothing, Number, AbstractVector{<:Number}},
    treatments::Union{Nothing, String, Vector{<:String}})

    df_result = copy(df)
    
    ret = twowayfeweights_normalize_var(df = df_result, varname = "D")

    if ret[:retcode]
        # To do : make it prettier.
        df_result = ret[:df]
        @info("The treatment variable in the regression varies within some group * period cells.")
        @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
        @info("with a group * period level treatment.")
        @info("The command will replace the treatment by its average value in each group * period.")
        @info("The results below apply to the two-way fixed effects regression with that treatment variable.")
    end


    if !isnothing(controls)
        
        controls = force_to_vector(controls)

        Threads.@threads for control in controls
            
            ret = twowayfeweights_normalize_var(df = df_result, varname = control)

            if ret[:retcode]
                df_result = ret[:df]
                @info("The control variable $control in the regression varies within some group * period cells.")
                @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
                @info("with controls apply to group * period level controls.")
                @info("The command will replace replace control variable $control by its average value in each group * period.")
                @info("The results below apply to the regression with control variable $control averaged at the group * period level.")
            end

        end

    end

    if !isnothing(treatments)
        
        treatments = force_to_vector(treatments)

        Threads.@threads for treatment in treatments
            
            ret = twowayfeweights_normalize_var(df = df_result, varname = treatment)
            
            if ret[:retcode]
                df_result = ret[:df]
                @info("The other treatment variable $treatment in the regression varies within some group * period cells.")
                @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
                @info("with several treatments apply to group * period level controls.")
                @info("The command will replace replace other treatment variable $treatment by its average value in each group * period.")
                @info("The results below apply to the regression with other treatment variable $treatment averaged at the group * period level.")
            end
        end
    end

    if isnothing(weights)
        df_result.weights .= 1
    else 
        df_result.weights .= weights
    end

    df_result.Tfactor       = CategoricalArrays.categorical(df_result.T)
    df_result.TFactorNum    = Int64.(CategoricalArrays.levelcode.(df_result.Tfactor))

    return df_result
end
