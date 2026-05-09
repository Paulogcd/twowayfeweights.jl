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
    D0::Union{String},
    cmd_type::Union{String},
    controls::Union{String, Vector{String}},
    treatments::Union{String, Vector{String}})

    # To define the column names so that they can be called correctly, we use the Symbol function.

    if(cmd_type != "fdTR")

        # In the original package, they seem to not allow for NA in the 
        # Y, G, T, D, controls, and treatments columns.
        # We are going to use the missing value instead.
        df = dropmissing(df, Symbol.([G, T, D, treatments]))
        df = dropmissing(df, Symbol.(controls))
    else

        # They allow for another case:
        # When at least one of D, T, and Y is not na (tag 1),
        # OR when D0 is not na (tag 2).
        df[!, :tag1] .= ismissing(df[!, c] for c in Symbol.([D, T, Y]))
        df[!, :tag2] .= ismissing(df[!, Symbol(D0)])
        df = df[df.tag1 .== 0 .| df.tag2 .== 0, :]
        
    end

    if length(controls) > 0
        # df[!, :tag3] .= ismissing.(df[!, Symbol.(controls)]) # former version
        df[!, :tag3] = [any(ismissing, row) for row in eachrow(df[:, Symbol.(controls)])]
        df = df[(df.tag1 .== 1) .| (df.tag3 .== 0), :]
        df = df[:, Not(:tag3)]
    end
        
    df = df[:, Not(:tag1, :tag2)]

    return df
end
# Work on the lmited case that the variables are defined with the same exact names
# :Y, :D, etc...
# Now, we must include the possibility to chose the names of the columns one wants to change.