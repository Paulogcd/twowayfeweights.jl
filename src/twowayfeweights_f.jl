function twowayfeweights(;
    data::DataFrames.DataFrame,
    Y::String,
    G::String,
    T::String,
    D::String,
    type = ["feTR", "feS", "fdTR", "fdS"],
    D0 = nothing,
    summary_measures = false,
    controls = nothing,
    weights = nothing,
    other_treatments = nothing,
    test_random_weights = nothing,
    path = nothing)

    # type = match.arg(tolower(type))
    #   type = match.arg(type) ? 
    if type == "fdTR" && isnothing(D0)
        @error("The `D0` argument must also be provided if `type = 'fdTR'`.\n")
    end

    if isnothing(other_treatments) && type != "feTR"
        @error("When the `other_treatments` argument is specified, you need to specify `type = 'feTR'` too.")
    end

    columns_to_check = ifelse(!isnothing(D0), [Y, G, T, D, D0], [Y, G, T, D])
    for v in columns_to_check
        if !(data[:, v] isa Vector{<:Number})
            data[:, v] = parse.(Float64, data[:, v]) # What about it cannot be parsed in Float64 but only 32 or 16?
            print(v)
        end
    end

    # We rename:
    controls_rename         = get_controls_rename(controls)
    treatments_rename       = get_treatments_rename(other_treatments)
    random_weight_rename    = get_random_weight_rename(test_random_weights)
    data_renamed = twowayfeweights_rename_var(
        df = data,
        Y = Y,
        G = G,
        T = T,
        D = D,
        D0 = D0,
        controls = controls,
        treatments = other_treatments,
        random_weights = test_random_weights)
  
    # Transform?
    data_transformed = twowayfeweights_transform(
        df = data_renamed,
        controls = controls_rename,
        weights = weights,
        treatments = test_random_weights)
    
    # Filter?
    data_filtered = twowayfeweights_filter(
        df = data_transformed,
        Y = "Y",
        G = "G",
        T = "T",
        D = "D",
        D0 = "D0",
        cmd_type = type,
        controls = controls_rename,
        treatments = treatments_rename)

    # Calculate the weights
    res = twowayfeweights_calculate(
        dat        = data_filtered,
        type       = type,
        controls   = controls_rename,
        treatments = treatments_rename
    )
  
    # Create main return object list (Not implemented yet)
    res = twowayfeweights_result(
        dat            = res[:dat],
        beta           = res[:beta],
        random_weights = random_weight_rename,
        treatments     = treatments_rename
    )

    # Set class and add extra features for post-processing (printing etc.)
    # class(res) = "twowayfeweights"
    
    res.type              = type
    res.params            = (;Y = Y, G = G, T = T, D = D, D0 = D0)
    res.summary_measures  = summary_measures
    res.other_treatments  = treatments_rename
    res.random_weights    = random_weight_rename
  
  
    if !(isnothing(path))
        # write.csv(res$dat_result, path, row.names = FALSE)
        CSV.write(path, res.dat_result)
    end
  
  return(res)
  
end