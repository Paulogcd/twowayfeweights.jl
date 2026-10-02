"""
Internal function used in the twowayfeweights_filter function.
"""
function na_count(df, cols)
    isempty(cols) && return zeros(Int, nrow(df))

    cols = Symbol.(cols)

    return [
        count(ismissing, df[i, cols])
        for i in axes(df, 1)
    ]
end

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

    if cmd_type != "fdTR"

        cols = vcat(
            [Y, G, T, D],
            something(controls, String[]),
            something(treatments, String[])
        )

        counts = na_count(df_result, cols)

        df_result = df_result[counts .== 0, :]

    else

        tag1 = na_count(df_result, [D, T, Y])
        tag2 = na_count(df_result, [D0])

        keep = (tag1 .== 0) .| (tag2 .== 0)

        df_result = df_result[keep, :]
        tag1 = tag1[keep]

        if !isnothing(controls) && !isempty(controls)
            tag3 = na_count(df_result, controls)

            df_result = df_result[
                (tag1 .== 1) .| (tag3 .== 0),
                :
            ]
        end
    end

    return df_result
end
# Work on the lmited case that the variables are defined with the same exact names
# :Y, :D, etc...
# Now, we must include the possibility to chose the names of the columns one wants to change.