
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

        if controls isa AbstractVector{<:AbstractString}

            for control in controls
                
                ret = twowayfeweights_normalize_var(df = df_result, varname = control)

                if ret[:retcode]
                    df_result = ret[:df]
                    @info("The control variable %s in the regression varies within some group * period cells.", control)
                    @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
                    @info("with controls apply to group * period level controls.")
                    @info("The command will replace replace control variable %s by its average value in each group * period.", control)
                    @info("The results below apply to the regression with control variable %s averaged at the group * period level.", control)
                end

            end

        elseif controls isa AbstractString

            for control in [controls]
                
                ret = twowayfeweights_normalize_var(df = df_result, varname = control)

                if ret[:retcode]
                    df_result = ret[:df]
                    @info("The control variable %s in the regression varies within some group * period cells.", control)
                    @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
                    @info("with controls apply to group * period level controls.")
                    @info("The command will replace replace control variable %s by its average value in each group * period.", control)
                    @info("The results below apply to the regression with control variable %s averaged at the group * period level.", control)
                end

            end

        end

    end

    if !isnothing(treatments)
        
        if treatments isa AbstractVector{<:String}

            for treatment in treatments
                
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

        elseif treatments isa String
            
            for treatment in [treatments]
                
                ret = twowayfeweights_normalize_var(df = df_result, varname = treatment)
                
                if ret[:retcode]
                    df_result = ret[:df]
                    @info("The other treatment variable $treatment in the regression varies within some group * period cells.")
                    @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
                    @info("with several treatments apply to group * period level controls.")
                    @info("The command will replace replace other $treatment variable %s by its average value in each group * period.")
                    @info("The results below apply to the regression with other $treatment variable %s averaged at the group * period level.")
                end
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
