
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
    controls::Union{String, Vector{String}, Nothing},
    weights::Union{AbstractVector, String, Vector{String}, Nothing},
    treatments::Union{String, Vector{String}, Nothing})

    # df_res = copy(df) # For testing purposes.
    df_res = df
    ret = twowayfeweights_normalize_var(df = df_res, varname = "D")

    if ret[:retcode]
        # To do : make it prettier.
        df_res = ret[:df]
        @info("The treatment variable in the regression varies within some group * period cells.")
        @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
        @info("with a group * period level treatment.")
        @info("The command will replace the treatment by its average value in each group * period.")
        @info("The results below apply to the two-way fixed effects regression with that treatment variable.")
    end

    if !isnothing(controls)

        if typeof(controls) == Vector{String}

            for control in controls
                
                ret = twowayfeweights_normalize_var(df = df_res, varname = control)

                if ret[:retcode]
                    df_res = ret[:df]
                    @info("The control variable %s in the regression varies within some group * period cells.", control)
                    @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
                    @info("with controls apply to group * period level controls.")
                    @info("The command will replace replace control variable %s by its average value in each group * period.", control)
                    @info("The results below apply to the regression with control variable %s averaged at the group * period level.", control)
                end

            end

        elseif typeof(controls) == String
                
            ret = twowayfeweights_normalize_var(df = df_res, varname = controls)

            if ret[:retcode]
                df_res = ret[:df]
                @info("The control variable %s in the regression varies within some group * period cells.", control)
                @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
                @info("with controls apply to group * period level controls.")
                @info("The command will replace replace control variable %s by its average value in each group * period.", control)
                @info("The results below apply to the regression with control variable %s averaged at the group * period level.", control)
            end

        end

    end

    if !isnothing(treatments)
        
        if typeof(treatments) == Vector{String}

            for treatment in treatments
                
                df_res = twowayfeweights_normalize_var(df = df_res, varname = treatment)
                
                if ret[:retcode]
                    df_res = ret[:df]
                    @info("The other treatment variable %s in the regression varies within some group * period cells.", treatment)
                    @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
                    @info("with several treatments apply to group * period level controls.")
                    @info("The command will replace replace other treatment variable %s by its average value in each group * period.", treatment)
                    @info("The results below apply to the regression with other treatment variable %s averaged at the group * period level.", treatment)
                end

            end

        elseif typeof(treatments) == String
            
            for treatment in [treatments]
                
                ret = twowayfeweights_normalize_var(df = df_res, varname = treatment)
                
                if ret[:retcode]
                    df_res = ret[:df]
                    @info("The other treatment variable %s in the regression varies within some group * period cells.", treatment)
                    @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
                    @info("with several treatments apply to group * period level controls.")
                    @info("The command will replace replace other treatment variable %s by its average value in each group * period.", treatment)
                    @info("The results below apply to the regression with other treatment variable %s averaged at the group * period level.", treatment)
                end
        
            end
        
        end

    end

    if isnothing(weights)
        df_res[!, :weights] .= 1
    else 
        # This is NOT what is expected?
        # The weights variable should be a numerical vector then?
        df_res[!, :weights] = weights
    end

    df_res[!, :Tfactor]         = CategoricalArrays.categorical(df_res[!, :T])
    df_res[!, :TFactorNum]      = Int64.(CategoricalArrays.levelcode.(df_res[!, :Tfactor]))

    return df_res
end
