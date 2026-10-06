"""
    twowayfeweights_summarize_weights(df, var_weight)

Computes the cardinal and the sum of the sets of the weights in a dataframe if they are positive or negative.
"""
function twowayfeweights_summarize_weights(;
    df::DataFrames.DataFrame,
    var_weight::Union{String, Vector{String}})

    w = df[!, Symbol(var_weight)]
    ok = .!ismissing.(w)

    weight_plus  = w[(ok) .&& w .> 0]
    weight_minus = w[ok .&& w .< 0]
   
    result = OrderedCollections.OrderedDict{Symbol, Any}(
        :nr_plus    => length(weight_plus),
        :nr_minus   => length(weight_minus),
        :nr_weights => length(weight_plus) + length(weight_minus),
        :sum_plus   => sum(weight_plus),
        :sum_minus  => sum(weight_minus)
    )

    return result
end