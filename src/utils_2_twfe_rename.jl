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
    random_weights::Union{String, Vector{String}, Nothing} # Can also be nothing.
    )

    # If random weights are provided, we rename and include them.
    if !isnothing(random_weights)
        random_weight_rename = get_random_weight_rename(random_weights)
        random_weight_df = DataFrames.DataFrame(df[!, DataFrames.names(df, random_weights)])
        DataFrames.rename!(random_weight_df, random_weights => random_weight_rename)
    end

    # We define the original and new names.
    original_names      = [Y, G, T, D]
    new_names           = ["Y", "G", "T", "D"]

    # If the treatments are provided, we rename and include it.
    # The original package did not define this step, however, looking
    # at the behavior of the main twowayfeweights function, this should be due to 
    # the NULL value being ignored when put in the columns argument in R. 
    # Since this is not the case in Julia, we treat the treatments = nothing separately:
    # Same for controls
    if !isnothing(controls)
        controls_rename     = get_controls_rename(controls)
        original_names      = vcat(original_names, controls)
        new_names           = vcat(new_names, controls_rename)
    end

    if !isnothing(treatments)
        treatments_rename   = get_treatments_rename(treatments)
        original_names      = vcat(original_names, treatments)
        new_names           = vcat(new_names, treatments_rename)
    end

    # If D0 is provided, we rename and include it.
    if !isnothing(D0)
        original_names  = vcat(original_names, D0)
        new_names       = vcat(new_names, "D0")
    end

    # We only select the original names in the dataframe, and we rename them.
    df = DataFrames.DataFrame(df[:, original_names])
    DataFrames.rename!(df, new_names)
    df = hcat(df, random_weight_df)

    return df
end
