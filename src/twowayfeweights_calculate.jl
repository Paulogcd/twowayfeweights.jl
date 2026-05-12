"""
Internal funcion for calculating the twoway FE weights.
"""
function twowayfeweights_calculate(;
    dat::DataFrames.DataFrame,
    type = ["feTR", "fdTR", "feS", "fdS"],
    controls::Union{String, Vector{String}},
    treatments::Union{String, Vector{String}})

    # type = match.arg(type) ?

    if (!isnothing(treatments) && type != "feTR")
        @error("When the `other_treatments` argument is specified, you need to specify `type = 'feTR'` too.")
    end

    type_TR = (type in ["feTR", "fdTR"])
    type_fe = (type in ["feTR", "feS"])

    if type_TR
        DVAR = type == "feTR" ? "D" : "D0"
        # mean_D = mean(skipmissing(dat[:, Symbol(DVAR)]), dat.weights)
        # Here, the original R package uses the function weighted.mean, which specifies: 
          # Missing values in w are not handled specially and so give a missing value as the result. 
          # However, zero weights are handled specially and the corresponding x values are omitted from the sum.
        # Also, I discovered this thread: 
        # https://discourse.julialang.org/t/re-weighted-statistics-with-missings/107502/20
        # And this issue: 
        # https://github.com/JuliaStats/Statistics.jl/issues/88
        # This seems like a *major* issue.
        # To reproduce the behavior of the original R package, I will define a function in the extra_utils file.
        mean_D = weighted_mean(x = dat[:, Symbol(DVAR)], w  = dat[:, :weights])
    end

    obs = sum(dat.weights)
    gdat = DataFrames.combine(DataFrames.groupby(dat, [:G, :T]), :weights .=> (x->sum(x)) .=> :P_gt)

    dat2 = DataFrames.leftjoin(dat, gdat, on = [:G, :T])
    dat.P_gt = DataFrames.combine(dat2, :P_gt => (x -> x .* (dat2[:, Symbol(DVAR)] ./ mean_D))) # This generates a 14 x 1 Df.
    # To fix.


    #     dplyr::summarise(P_gt = sum(.data$weights)) %>% dplyr::ungroup()
    # dat = dat %>% 
    #     dplyr::left_join(gdat, by=c("T", "G")) %>% 
    #     dplyr::mutate(P_gt = .data$P_gt / obs)
    
    if type_TR
        # dat = dplyr::mutate(dat, nat_weight = .data$P_gt * .data[[DVAR]] / mean_D)
    end

    if (isnothing(controls))
        controls = 1
    end

    fes = "Tfactor"

    if type_fe
        fes = ["G", fes]
    end
  
    # Add non-NULL treatment vars
    xvars = [controls, treatments]

    if type == "fdS"
        # denom.lm = ...
    else 
        # denom.lm = ...
    end

    if type_fe
        EPS_VAR = "eps_1"
    else
        EPS_VAR = "eps_2"
    end

    if type_fe || type == "fdS"
        # dat[:, Symbol(EPS_VAR)] = residual...(denom.lm)
    end

  
  # GM: could we make this if(!type_TR), combined with weights !=0 above?
#   if (type_fe || type=="fdS") {
#     dat[[EPS_VAR]] = resid(denom.lm)
#   } else if (type == "fdTR") {
#     dat[[EPS_VAR]] = resid(denom.lm, na.rm = FALSE)
#     dat[[EPS_VAR]] = ifelse(is.na(dat[[EPS_VAR]]), 0, dat[[EPS_VAR]])
#   }
  

    return OrderedCollections.OrderedDict(:dat => dat, beta => :beta)

end