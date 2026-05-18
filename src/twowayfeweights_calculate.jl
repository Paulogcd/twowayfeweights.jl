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
        # mean_D = weighted_mean(x = dat[:, Symbol(DVAR)], w  = dat[:, :weights])
        mean_D = TwoWayFEWeights.weighted_mean(x = dat[:, Symbol(DVAR)], w  = dat[:, :weights])
        # To fix.
    end

    obs = sum(dat.weights)
    gdat = DataFrames.combine(DataFrames.groupby(dat, [:G, :T]), :weights .=> (x->sum(x)) .=> :P_gt)

    dat = DataFrames.leftjoin(dat, gdat, on = [:G, :T])
    dat = DataFrames.transform(dat, :P_gt => (x -> x ./ obs) => :P_gt)
    
    if type_TR
        dat = DataFrames.transform(dat, :P_gt => (x -> x .* (dat[:, Symbol(DVAR)] ./ mean_D)) => :nat_weight)
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

        dat[:, :eps_1_weight] = dat[:, Symbol(EPS_VAR)] .* dat[:, :weights]
        sort!(dat, [:G, :Tfactor])
        gdat = DataFrames.groupby(dat, [:G])

        # Here, there is a (classic?) problem with operations on grouped dataframe.
        # We cannot modify them as we would for a standard dataframe, so we use the transform! (note the !)
        # to modify gdat.
        transform!(gdat, :eps_1_weight => (x -> reverse(cumsum(reverse(x)))) => :E_eps_1_g_ge_aux)
        # dplyr::mutate(E_eps_1_g_ge_aux = rev(cumsum(rev(.data$eps_1_weight)))) %>%
        
        transform!(gdat, :weights => (x -> reverse(cumsum(reverse(x)))) => :weights_aux)
        # dplyr::mutate(weights_aux = rev(cumsum(rev(.data$weights))))
        
        transform!(gdat, [:E_eps_1_g_ge_aux, :weights_aux] => ((x, y) -> (x ./ y)) => :E_eps_1_g_ge)
        # dplyr::mutate(E_eps_1_g_ge = .data$E_eps_1_g_ge_aux / .data$weights_aux) %>% dplyr::ungroup()
    
    elseif type == "fdTR"
        dat[:, :eps_2] = ifelse(ismissing(dat[:, Symbol(EPS_VAR)]), 0, dat[:, Symbol(EPS_VAR)])
    end

    # New regression
    push!(xvars, "D")

    if type == "fdS"
        dat_regression = dat[dat[:, :weights] .!= 0,:]

        # regressors in xvar
        rhs = sum(term.(Symbol.(xvars)))
        # fixed effects
        fe_terms = sum(fe.(term.(Symbol.(fes))))
        # full formula
        ff = term(:D) ~ rhs + fe_terms

        beta_lm = reg(dat_regression, ff, weights = :weights, save = :all)

    else
        # regressors in xvar
        rhs = sum(term.(Symbol.(xvars)))
        # fixed effects
        fe_terms = sum(fe.(term.(Symbol.(fes))))
        # full formula
        ff = term(:D) ~ rhs + fe_terms

        beta_lm = reg(dat, ff, save = :residuals)

    end
    
    # Is there a better way to select the beta of the D variable?
    beta = coef(beta_lm)[coefnames(beta_lm) .== "D"]
    
    if type == "feTR"
        # Original comment:
        # * Keeping only one observation in each group * period cell
        # This should be done after this function
        # bys `group' `time': gen group_period_unit=(_n==1)	
        # 	drop if group_period_unit==0
        # 	drop group_period_unit
        gdat = DataFrames.groupby(dat, [:G, :Tfactor])
        sdat = combine(gdat) do sdf
            sdf[argmin(sdf.D), :] # This seems off, as we are already using a dataframe with only one observation per G * T
        end

    elseif type == "fdTR"
        
    # À faire.
    # dat = dat %>% 
    #   dplyr::arrange(.data$G, .data$TFactorNum) %>%
    #   dplyr::group_by(.data$G) %>% 
    #   dplyr::mutate(w_tilde_2 = ifelse(.data$TFactorNum + 1 == dplyr::lead(.data$TFactorNum), .data$eps_2 - dplyr::lead(.data$eps_2) * (dplyr::lead(.data$P_gt) / .data$P_gt), NA)) %>%
    #   dplyr::mutate(w_tilde_2 = ifelse(is.na(.data$w_tilde_2) | is.infinite(.data$w_tilde_2), .data$eps_2, .data$w_tilde_2)) %>%
    #   dplyr::mutate(w_tilde_2_E_D_gt = .data$w_tilde_2 * .data$D0) %>% dplyr::ungroup()

    # dat = DataFrames.sort(dat, [:G, :TFactorNum])
    # gdat = DataFrames.combine(
    #     DataFrames.groupby(dat, [:G]),
    #     w_tilder_2 = ifelse(dat.TFactorNum + 1 == dat)
    # )

    
    denom_W = weighted.mean(dat$w_tilde_2_E_D_gt, dat$P_gt, na.rm = TRUE)
    dat = dat %>% 
      # dplyr::mutate(W = .data$w_tilde_2 * mean_D0 / denom_W) %>% 
      dplyr::mutate(W = .data$w_tilde_2 * mean_D / denom_W) %>% 
      dplyr::mutate(weight_result = .data$W * .data$nat_weight)
    dat = dat %>%
      dplyr::select(-.data$eps_2, -.data$P_gt, -.data$w_tilde_2, -.data$w_tilde_2_E_D_gt)
    
        
    elseif type == "feS"
    
    end

    return OrderedCollections.OrderedDict(:dat => dat, beta => :beta)

end