function parse_float_or_missing(x)
    try
        parse(Float64, x)
    catch
        missing
    end
end

function weighted_mean(x::Vector{T}, w::Vector{W})::Real where {T<:Union{Missing, Real}, W<:Union{Missing, Real}}
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

# Mimic the stats::weighted.mean(x, w, na.rm = TRUE) function in R 
function stats_weighted_mean_na_rm(x::Vector{T}, w::Vector{W})::Real where {T<:Union{Missing, Real}, W<:Union{Missing, Real}}
    
    x = x |> skipmissing |> collect
    
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

function weighted_mean(x::Vector{T}, w::Vector{W})::Real where {T<:Real, W<:Real}
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

function rev_cumsum_by_group(g::Vector{T}, x::Vector{W}) where {T<:Union{Missing, Real}, W<:Union{Missing, Real}}

    n = length(g)
    length(x) == n || throw(ArgumentError(
        "rev_cumsum_by_group: g and x must have equal length"
    ))

    out = Vector{Float64}(undef, n)
    n == 0 && return out

    end_idx = n

    while end_idx >= 1
        gid = g[end_idx]

        start_idx = end_idx
        while start_idx > 1 && g[start_idx - 1] == gid
            start_idx -= 1
        end

        acc = BigFloat(0)
        for i in start_idx:end_idx
            xi = x[i]
            if !ismissing(xi)
                acc += BigFloat(xi)
            end
        end

        running = acc
        for i in start_idx:end_idx
            out[i] = Float64(running)

            xi = x[i]
            if !ismissing(xi)
                running -= BigFloat(xi)
            end
        end

        end_idx = start_idx - 1
    end

    out
end

function fdtr_wtilde2(
    g::Vector{Int},
    t::Vector{Float64},
    eps_2::Vector{Float64},
    P_gt::Vector{Float64},
)::Vector{Float64}

    n = length(g)

    if length(t) != n || length(eps_2) != n || length(P_gt) != n
        throw(ArgumentError(
            "fdtr_wtilde2: all inputs must have equal length"
        ))
    end

    out = Vector{Float64}(undef, n)

    for i in 1:n
        eps_i = eps_2[i]
        val = NaN

        # C++: (i + 1 < n) && (g[i + 1] == g[i])
        # Julia's next element is i + 1, because indexing starts at 1.
        has_next = i < n && g[i + 1] == g[i]

        if has_next
            t_i = t[i]
            t_n = t[i + 1]
            P_i = P_gt[i]
            P_n = P_gt[i + 1]
            e_n = eps_2[i + 1]

            if !isnan(t_i) &&
               !isnan(t_n) &&
               (t_i + 1.0 == t_n) &&
               !isnan(P_i) &&
               P_i != 0.0 &&
               !isnan(P_n) &&
               !isnan(e_n) &&
               !isnan(eps_i)

                val = eps_i - e_n * (P_n / P_i)
            end
        end

        # C++: if (is_na(val) || !isfinite(val)) val = eps_i;
        if isnan(val) || !isfinite(val)
            val = eps_i
        end

        out[i] = val
    end

    return out
end

function fdtr_wtilde2(
    g::Vector{G},
    t::AbstractVector{T},
    eps_2::AbstractVector{W},
    P_gt::AbstractVector{X},
)::Vector{Union{Missing, Float64}} where {
    G <: Integer,
    T <: Union{Missing, Real},
    W <: Union{Missing, Real},
    X <: Union{Missing, Real},
}

    n = length(g)

    if length(t) != n || length(eps_2) != n || length(P_gt) != n
        throw(ArgumentError(
            "fdtr_wtilde2: all inputs must have equal length"
        ))
    end

    out = Vector{Union{Missing, Float64}}(undef, n)

    for i in 1:n
        eps_i = eps_2[i]
        val = NaN

        # C++: (i + 1 < n) && (g[i + 1] == g[i])
        has_next = i < n && g[i + 1] == g[i]

        if has_next
            t_i = t[i]
            t_n = t[i + 1]
            P_i = P_gt[i]
            P_n = P_gt[i + 1]
            e_n = eps_2[i + 1]

            # Treat both missing and NaN as invalid, like R's NA handling.
            if !ismissing(t_i) &&
               !ismissing(t_n) &&
               !isnan(t_i) &&
               !isnan(t_n) &&
               (t_i + 1.0 == t_n) &&
               !ismissing(P_i) &&
               !isnan(P_i) &&
               P_i != 0.0 &&
               !ismissing(P_n) &&
               !isnan(P_n) &&
               !ismissing(e_n) &&
               !isnan(e_n) &&
               !ismissing(eps_i) &&
               !isnan(eps_i)

                val = eps_i - e_n * (P_n / P_i)
            end
        end

        # C++:
        # if (is_na(val) || !isfinite(val)) val = eps_i;
        #
        # If eps_i is missing, this naturally preserves missing.
        if isnan(val) || !isfinite(val)
            val = eps_i
        end

        out[i] = val
    end

    return out
end


function feS_delta(
    g::Vector{Int}, t::Vector{T}, D::Vector{W}, P_gt::Vector{X}
    )::DataFrames.DataFrame where {T<:Real, W<:Real, X<:Real}

    n = length(g)

    if length(t) != n || length(D) != n || length(P_gt) != n
        throw(ArgumentError(
            "feS_delta: all inputs must have equal length"
        ))
    end

    delta_D     = fill(NaN, n)
    s_gt        = zeros(Int, n)
    abs_delta_D = fill(NaN, n)
    nat_weight  = fill(NaN, n)
    keep        = falses(n)

    for i in 1:n

        # C++: (i > 0) && (g[i - 1] == g[i])
        # Julia: previous element is i - 1
        has_prev = i > 1 && g[i - 1] == g[i]

        ok = false
        dD = NaN

        if has_prev
            t_i = t[i]
            t_p = t[i - 1]

            if !isnan(t_i) &&
               !isnan(t_p) &&
               (t_i - 1.0 == t_p) &&
               !isnan(D[i]) &&
               !isnan(D[i - 1])

                dD = D[i] - D[i - 1]
                ok = !isnan(dD)
            end
        end

        if ok
            delta_D[i] = dD

            a = abs(dD)
            abs_delta_D[i] = a

            s_gt[i] = dD > 0.0 ? 1 : (dD < 0.0 ? -1 : 0)

            pgt = P_gt[i]
            nat_weight[i] = isnan(pgt) ? NaN : pgt * a

            keep[i] = true
        end
    end

    return DataFrames.DataFrame(
        delta_D     = delta_D,
        s_gt        = s_gt,
        abs_delta_D = abs_delta_D,
        nat_weight  = nat_weight,
        keep        = keep
    )
end

