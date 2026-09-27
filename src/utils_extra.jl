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
# w = y
# weighted_mean(x = x, w = w)

function weighted_mean(x::Vector{T}, w::Vector{W}) where {T<:Union{Missing, Real}, W<:Union{Missing, Real}}
    x_length = length(x)
    if length(w) != x_length @error("weighted_mean: x and w must have equal length") end
    num, den = zeros(2);
    for i in 1:x_length
        xi, wi = x[i], w[i];
        if ismissing(xi) || ismissing(wi)
            continue
        else
            num += xi * wi
            den += wi
        end
    end
    if den == 0
        return NaN
    else 
        return num / den
    end
end

function weighted_mean(x::Vector{T}, w::Vector{W}) where {T<:Real, W<:Real}
    x_length = length(x)
    if length(w) != x_length @error("weighted_mean: x and w must have equal length") end
    num, den = zeros(2);
    for i in 1:x_length
        xi, wi = x[i], w[i];
        num += xi * wi
        den += wi
    end
    if den == 0
        return NaN
    else 
        return num / den
    end
end

# weighted_mean(x, y)
# weighted_mean(x, y)
# weighted_mean([1, 2, 3], [1, 2, 3])