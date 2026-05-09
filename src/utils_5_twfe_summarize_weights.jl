"""
    twowayfeweights_summarize_weights(df, var_weight)

Computes the cardinal and the sum of the sets of the weights in a dataframe if they are positive or negative.
"""
function twowayfeweights_summarize_weights(;
    df::DataFrames.DataFrame,
    var_weight::Union{String, Vector{String}})

    var_weight = Symbol(var_weight)

    # First, we take the list of weights that are positive and not missing.
    weight_plus     = df[(df[!, var_weight] .> 0 .& ismissing.(df[!, var_weight])), var_weight]
    nr_plus         = length(weight_plus)
    sum_plus        = sum(weight_plus)    

    weight_minus    = df[(df[!, var_weight] .< 0 .& ismissing.(df[!, var_weight])), var_weight]
    nr_minus        = length(weight_minus)
    sum_minus       = sum(nr_minus)

    nr_weights = nr_plus + nr_minus
   
    result = OrderedCollections.OrderedDict(
        :nr_plus    => nr_plus,
        :nr_minus   => nr_minus,
        :nr_weights => nr_weights,
        :sum_plus   => sum_plus,
        :sum_minus  => sum_minus)

    return result
end