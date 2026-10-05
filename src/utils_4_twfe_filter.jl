"""
Internal function used in the twowayfeweights_filter function.
"""
function na_count(df, cols)
    n = nrow(df)
    counts = zeros(Int, n)

    for col in cols
        x = df[!, col]
        @inbounds for i in 1:n
            counts[i] += ismissing(x[i])
        end
    end

    return counts
end

function complete_rows(df, cols)
    keep = trues(nrow(df))

    for col in cols
        x = df[!, col]
        @inbounds for i in eachindex(x)
            keep[i] &= !ismissing(x[i])
        end
    end

    return keep
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
    # df_result = copy(df)
    # But we should, as it would be more efficient...
    df_result = df

    if cmd_type != "fdTR"

        cols = vcat(
            [Y, G, T, D],
            something(controls, String[]),
            something(treatments, String[])
        )

        keep = complete_rows(df_result, Symbol.(cols))
        df_result = df_result[keep, :]

    else

        tag1 = complete_rows(df_result, Symbol.([D, T, Y]))
        tag2  = complete_rows(df_result, Symbol.([D0]))

        keep = tag1 .| tag2

        df_result = df_result[keep, :]
        tag1 = tag1[keep]

        if !isnothing(controls) && !isempty(controls)
            complete_controls = complete_rows(df_result, Symbol.(controls))

            keep = .!tag1 .| complete_controls
            df_result = df_result[keep, :]
        end

    end

    return df_result
end
# Work on the lmited case that the variables are defined with the same exact names
# :Y, :D, etc...
# Now, we must include the possibility to chose the names of the columns one wants to change.