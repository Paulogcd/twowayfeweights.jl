"""
Internal funcion for calculating the twoway FE weights.
"""
function twowayfeweights_calculate(;
    dat::DataFrames.DataFrame,
    type = ["feTR", "fdTR", "feS", "fdS"],
    controls::Union{String, Vector{String}},
    treatments::Union{String, Vector{String}})

    # type = match.arg(type) ?

    dat = random_data_frame_test
    type = "feTR"
    controls = "control_1"
    treatments = "D0"

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

    dat = DataFrames.leftjoin(dat, gdat, on = [:G, :T])
    dat = DataFrames.transform(dat, :P_gt => (x -> x ./ obs) => :P_gt)
    
    if type_TR
        dat = DataFrames.transform(dat2, :P_gt => (x -> x .* (dat2[:, Symbol(DVAR)] ./ mean_D)) => :nat_weight)
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
        
        dat_regression = dat[dat[:, :weights] .!= 0,:]

        # regressors in xvar
        rhs = sum(term.(Symbol.(xvars)))
        # fixed effects
        fe_terms = sum(fe.(term.(Symbol.(fes))))
        # full formula
        ff = term(:D) ~ rhs + fe_terms

        denom_lm = reg(dat_regression, ff, weights = :weights, save = :residuals)
        # This can also be obtained with: 
        # denom.lm = FixedEffectModels.reg(dat, @formula(D ~ control_1 + D0 + fe(G) + fe(Tfactor)), weights = :weights)

        # Original regression in R:
        # denom.lm = feols(D ~ .[xvars] | .[fes], data = subset(dat, weights!=0), weights = dat$weights)
    else 
        # regressors in xvars
        rhs = sum(term.(Symbol.(xvars)))
        # fixed effects
        fe_terms = sum(fe.(term.(Symbol.(fes))))
        # full formula
        ff = term(:D) ~ rhs + fe_terms
        denom_lm = reg(dat, ff, weights = :weights, save = :residuals)
        # denom.lm = feols(D ~ .[xvars] | .[fes], data = dat, weights = dat$weights)
    end

    if type_fe
        EPS_VAR = "eps_1"
    else
        EPS_VAR = "eps_2"
    end

    if type_fe || type == "fdS"
        dat[:, Symbol(EPS_VAR)] = residuals(denom_lm)
    elseif type == "fdTR"
        dat[:, Symbol(EPS_VAR)] = skipmissing.(residuals(denom_lm))
        dat[:, Symbol(EPS_VAR)] = ifelse.(ismissing.(dat[:, Symbol(EPS_VAR)]), 0, dat[:, Symbol(EPS_VAR)])
    end
    
    # Beta reg ----
    if type == "feTR"
    
        dat[:, "eps_1_E_D_gt"] = dat[:, Symbol(EPS_VAR)] .* dat[:, Symbol(DVAR)]
    
        if isnothing(treatments)
            denom_W = weighted_mean(x = dat[:, :eps_1_E_D_gt], w = dat[:, :weights])
        else
            denom_W = mean(skipmissing(dat[:, :eps_1_E_D_gt]))
        end

        dat[:, :W] = dat[:, Symbol(EPS_VAR)] .* mean_D / denom_W
        dat[:, :weighted_result] = dat[:, :W] .* dat[:, :nat_weight]

        if !isnothing(treatments)
            for treatment in treatments
                varname = fn_treatment_weight_rename(treatment)
                dat[:, Symbol(varname)] = dat[:, :W] .* dat[:, :P_gt] * dat[:, Symbol(treatment)] / mean_D
            end
        end

        dat = dat[:, Not(Symbol(EPS_VAR), "P_gt")]
        
    elseif type == "feS"

        # EN COURS !!
        dat[:, :eps_1_weight] = dat[:, Symbol(EPS_VAR)] .* dat[:, :weights]
        dplyr::mutate(eps_1_weight = .data[[EPS_VAR]] * .data$weights) %>%
        dplyr::arrange(.data$G, .data$Tfactor) %>%
        gdat = DataFrames.groupby(dat, [:G, :T])
        dplyr::group_by(.data$G) %>%
        dplyr::mutate(E_eps_1_g_ge_aux = rev(cumsum(rev(.data$eps_1_weight)))) %>%
        dplyr::mutate(weights_aux = rev(cumsum(rev(.data$weights)))) %>%
        dplyr::mutate(E_eps_1_g_ge = .data$E_eps_1_g_ge_aux / .data$weights_aux) %>% dplyr::ungroup()
    
    elseif type == "fdTR"

    end

  else if (type=="feS") {
    
    dat = dat %>% 
      dplyr::mutate(eps_1_weight = .data[[EPS_VAR]] * .data$weights) %>%
      dplyr::arrange(.data$G, .data$Tfactor) %>%
      dplyr::group_by(.data$G) %>%
      dplyr::mutate(E_eps_1_g_ge_aux = rev(cumsum(rev(.data$eps_1_weight)))) %>%
      dplyr::mutate(weights_aux = rev(cumsum(rev(.data$weights)))) %>%
      dplyr::mutate(E_eps_1_g_ge = .data$E_eps_1_g_ge_aux / .data$weights_aux) %>% dplyr::ungroup()
    
  } else if (type=="fdTR") {
    
    dat = dat %>% 
      dplyr::mutate(eps_2 = ifelse(is.na(.data[[EPS_VAR]]), 0, .data[[EPS_VAR]])) # dup with l. 55?
    
  }

    return OrderedCollections.OrderedDict(:dat => dat, beta => :beta)

end