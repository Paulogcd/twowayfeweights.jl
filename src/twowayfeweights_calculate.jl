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
        DVAR = [type == "feTR" ? "D" : "D0"]
        mean_D = mean(skipmissing.(dat[:,:DVAR]), dat.weights)
    end

    # obs = sum(dat.weights)
    # gdat = dat %>%
    # gdat = DataFrames.group_by(dat, [G, T])
    #     dplyr::group_by(.data$G, .data$T) %>%
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