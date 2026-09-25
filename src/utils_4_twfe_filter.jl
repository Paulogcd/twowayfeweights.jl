"""
    twowayfeweights_filter(df_result, Y, G, T, D, D0, cmd_type, controls, treatments)

Description.
"""
function twowayfeweights_filter(;
    df::Union{DataFrames.DataFrame},
    Y::Union{String},
    G::Union{String},
    T::Union{String}, 
    D::Union{String},
    D0::Union{String, Nothing},
    cmd_type::Union{String},
    controls::Union{String, Vector{String}, Nothing},
    treatments::Union{String, Vector{String}, Nothing})

    # We rename the df variable to not modify the df input object.
    df_result = copy(df)
    # To define the column names so that they can be called correctly, we use the Symbol function.

    if (cmd_type != "fdTR")

        # In the original package, they seem to not allow for NA in the 
        # Y, G, T, D, controls, and treatments columns.
        # We are going to use the missing value instead.
        columns_to_filter = ifelse(isnothing(treatments), vcat(Y, G, T, D), vcat(G, T, D, treatments))
        columns_to_filter = ifelse(isnothing(controls), columns_to_filter, vcat(columns_to_filter, controls))
        
        # This does not work, so we replace by the former dropmissing function.
        # df_result[!, :tag] .= ismissing(df_result[!, c] for c in Symbol.(columns_to_filter))
        # df_result = df_result[df_result.tag .== 0, :]
        # df_result = df_result[:, Not(:tag)]
        df_result = dropmissing(df_result, columns_to_filter)

    else

        # They allow for another case:
        # When at least one of D, T, and Y is not na (tag 1),
        # OR when D0 is not na (tag 2).
        df_result[!, :tag1] .= ismissing(df_result[!, c] for c in Symbol.([D, T, Y]))
        df_result[!, :tag2] .= ismissing(df_result[!, Symbol(D0)])
        df_result = df_result[df_result.tag1 .== 0 .| df_result.tag2 .== 0, :]
    
        if !isnothing(controls)
            # df_result[!, :tag3] .= ismissing.(df_result[!, Symbol.(controls)]) # former version
            df_result[!, :tag3] = [any(ismissing, row) for row in eachrow(df_result[:, Symbol.(controls)])]
            df_result = df_result[(df_result.tag1 .== 1) .| (df_result.tag3 .== 0), :]
            df_result = df_result[:, Not(:tag3)]
        end
    end
    
    if "tag1" in DataFrames.names(df_result)
        df_result = df_result[:, Not(:tag1)]
    end

    if "tag2" in DataFrames.names(df_result)
        df_result = df_result[:, Not(:tag2)]
    end

    return df_result
end
# Work on the lmited case that the variables are defined with the same exact names
# :Y, :D, etc...
# Now, we must include the possibility to chose the names of the columns one wants to change.