
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
    controls::Union{String, Vector{String}},
    weights::Union{String, Vector{String}, Nothing},
    treatments::Union{String, Vector{String}, Nothing})

    ret = twowayfeweights_normalize_var(df = df, varname = "D")

    if ret[:retcode] # if ret is a list, we can use "." instead of "$"
        # To do : make it prettier by making use of the wonders of Julia REPL possibilities.
        df = ret[:df]
        @info("The treatment variable in the regression varies within some group * period cells.")
        @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
        @info("with a group * period level treatment.")
        @info("The command will replace the treatment by its average value in each group * period.")
        @info("The results below apply to the two-way fixed effects regression with that treatment variable.")
    end


    for control in controls
        
        ret = twowayfeweights_normalize_var(df = df, varname = control)

        if ret[:retcode]
            df = ret[:df]
            @info("The control variable %s in the regression varies within some group * period cells.", control)
            @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
            @info("with controls apply to group * period level controls.")
            @info("The command will replace replace control variable %s by its average value in each group * period.", control)
            @info("The results below apply to the regression with control variable %s averaged at the group * period level.", control)
        end
    end

    for treatment in treatments
        
        ret = twowayfeweights_normalize_var(df = df, varname = treatment)
        
        if ret[:retcode]
            df = ret[:df]
            @info("The other treatment variable %s in the regression varies within some group * period cells.", treatment)
            @info("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
            @info("with several treatments apply to group * period level controls.")
            @info("The command will replace replace other treatment variable %s by its average value in each group * period.", treatment)
            @info("The results below apply to the regression with other treatment variable %s averaged at the group * period level.", treatment)
        end
    end

    if weights == [] # possible equivalent for is.null in R?
        df.weights = 1
    else 
        # This is NOT what is expected.
        # The weights variable should be a numerical vector then?
        df.weights = repeat(weights, nrow(df))
    end

    df.Tfactor = CategoricalArrays.categorical(string.(df.T))
    df.TFactorNum = Int64.(df.T)

    return df
end
