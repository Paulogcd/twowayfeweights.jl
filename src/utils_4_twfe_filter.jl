"""
    twowayfeweights_filter(df, Y, G, T, D, D0, cmd_type, controls, treatments)

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

    # To define the column names so that they can be called correctly, we use the Symbol function.

    if (cmd_type != "fdTR")

        # In the original package, they seem to not allow for NA in the 
        # Y, G, T, D, controls, and treatments columns.
        columns_to_filter = ifelse(isnothing(controls), vcat(Y, G, T, D), vcat(Y, G, T, D, controls))
        columns_to_filter = ifelse(isnothing(treatments), columns_to_filter, vcat(columns_to_filter, treatments))
        # columns_to_filter = vcat(Y, G, T, D, controls, treatments)
        # if !isnothing(controls)
        #     vcat(columns_to_filter, controls)
        # end
        df = dropmissing(df, columns_to_filter)
    else

        # They allow for another case:
        # When at least one of D, T, and Y is not na (tag 1),
        # OR when D0 is not na (tag 2).
        df[!, :tag1] .= ismissing(df[!, c] for c in Symbol.([D, T, Y]))
        df[!, :tag2] .= ismissing(df[!, Symbol(D0)])
        df = df[df.tag1 .== 0 .| df.tag2 .== 0, :]
       
        if !isnothing(controls)
            # df[!, :tag3] .= ismissing.(df[!, Symbol.(controls)]) # former version
            df[!, :tag3] = [any(ismissing, row) for row in eachrow(df[:, Symbol.(controls)])]
            df = df[(df.tag1 .== 1) .| (df.tag3 .== 0), :]
            df = df[:, Not(:tag3)]
        end
        
    end
        
    if "tag1" in names(df)
        df = df[:, Not(:tag1)]
    end

    if "tag2" in names(df)
        df = df[:, Not(:tag2)]
    end

    return df
end
# Work on the lmited case that the variables are defined with the same exact names
# :Y, :D, etc...
# Now, we must include the possibility to chose the names of the columns one wants to change.