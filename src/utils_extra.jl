"""
  Returns a weighted mean for internal computation.
  Sends a warning if there are any missing values in the weights.
"""
function weighted_mean(;x, w, warnings = true)

    if warnings & any(ismissing.(w))
        @warn("The weights contain missing data.
        If the associated x value is not missing, the weighted average will be missing.
        To avoid this, please drop the missing values.")
    end

    x_missing = .!ismissing.(x)
    x_without_missing = x[x_missing]
    w_without_x_missing = w[x_missing]

    if warnings & (sum(x_missing) < length(x))
        @warn("The x values contain some missing values.
        They will be skipped, as in the original R package.")
    end

    if warnings & (any(ismissing.(w)) || sum(x_missing) < length(x))
        @warn("To not print warning messages, use `warnings = false` in the function.")
    end

    result = sum((x_without_missing .* w_without_x_missing)) ./ sum(w)

    return result
end
# x = [1, 2, 3]
# y = [1, missing, 3]
# weighted_mean(x = x, w = w)
