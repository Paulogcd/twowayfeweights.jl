"""
    twowayfeweights_rename_var(df, Y, G, T, D, D0, controls, treatments, random_weights)

Return a dataframe with renamed variables.
"""
function twowayfeweights_rename_var(;
    df::Union{DataFrames.DataFrame}, # Maybe we should include another type, like Matrix.
    Y::Union{String, Vector{String}},
    G::Union{String, Vector{String}},
    T::Union{String, Vector{String}},
    D::Union{String, Vector{String}},
    D0::Union{String, Vector{String}, Nothing}, # Can be nothing. To do : check all the possible types of each parameter.
    controls::Union{String, Vector{String}, Nothing},
    treatments::Union{String, Vector{String}, Nothing},
    random_weights::Union{String, Vector{String}, Nothing})

    controls_rename = get_controls_rename(controls)
    treatments_rename = get_treatments_rename(treatments)

    # If random weights are provided, we rename and include them.
    if !isnothing(random_weights)
        random_weight_rename = get_random_weight_rename(random_weights)
        random_weight_df = df[!, DataFrames.names(df, random_weights)]
        DataFrames.rename!(random_weight_df, random_weights => random_weight_rename)
    end
    
    # We define the original and new names.
    original_names      = vcat(Y, G, T, D, controls, treatments)
    new_names           = vcat("Y", "G", "T", "D", controls_rename, treatments_rename)

    # If D0 is provided, we rename and include it.
    if !isnothing(D0)
        original_names  = vcat(original_names, D0)
        new_names       = vcat(new_names, "D0")
    end

    # We only select the original names in the dataframe, and we rename them.
    df = DataFrames.DataFrame(df[:, original_names])
    DataFrames.rename!(df, new_names)

    if !isnothing(random_weights)
        df = hcat(df, random_weight_df)
    end

    return df
end
