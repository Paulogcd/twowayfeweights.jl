"""
Internal funcion for calculating the twoway FE weights.
"""
function twowayfeweights_calculate(;
    dat::DataFrames.DataFrame,
    type::String,
    controls::Union{String, Vector{String}, Vector{Any}, Nothing},
    treatments::Union{String, Vector{String}, Nothing})

    if (!isnothing(treatments) && type != "feTR")
        @error("When the `other_treatments` argument is specified, you need to specify `type = 'feTR'` too.")
    end

    type_TR = (type in ["feTR", "fdTR"])
    type_fe = (type in ["feTR", "feS"])

    if type_TR
        DVAR = type == "feTR" ? :D : :D0
        mean_D = weighted_mean(dat[:, DVAR], dat[:, :weights])
    end

    obs = sum(dat.weights)
    gdat = DataFrames.combine(
        DataFrames.groupby(dat, [:G, :T]),
        :weights .=> (x->sum(x)) .=> :P_gt
    )
    dat = DataFrames.leftjoin(dat, gdat, on = [:G, :T])
    dat = DataFrames.transform(dat, :P_gt => (x -> x ./ obs) => :P_gt)
        
    if type_TR
        dat = DataFrames.transform(
            dat, 
            :P_gt => (x -> x .* (dat[:, DVAR] ./ mean_D)) => :nat_weight
        )
    end

    # Denominator regression

    # Controls
    controls_terms = isnothing(controls) ?
        Term[] :
        term.(Symbol.(controls))

    # Treatments
    treatment_terms = isnothing(treatments) ?
        Term[] :
        term.(Symbol.(treatments))

    # RHS: controls + treatments
    rhs_terms = vcat(controls_terms, treatment_terms) # xvars in R code

    # Fixed effects
    fe_names = type_fe ? [:G, :Tfactor] : [:Tfactor]
    fe_terms = fe.(term.(fe_names))

    # Construct RHS
    rhs = isempty(rhs_terms) ? ConstantTerm(1) : sum(rhs_terms)

    # Add fixed effects as part of the RHS
    fml = term(:D) ~ rhs + sum(fe_terms)

    if type == "fdS"
        dat_regression = dat[dat[:, :weights] .!= 0,:]
        denom_lm = FixedEffectModels.reg(dat_regression, fml, weights = :weights, save = :all)
    else 
        denom_lm = FixedEffectModels.reg(dat, fml, weights = :weights, save = :all)
    end

    EPS_VAR = type_fe ? "eps_1" : "eps_2"

    if type_fe || type == "fdS"
        dat[:, Symbol(EPS_VAR)] = residuals(denom_lm)
    elseif type == "fdTR"
        dat[:, Symbol(EPS_VAR)] .= residuals(denom_lm)
        dat[:, Symbol(EPS_VAR)] = ifelse.(ismissing.(dat[:, Symbol(EPS_VAR)]), 0, dat[:, Symbol(EPS_VAR)])
    end
    
    # Beta regression ----
    xvars_beta = vcat(term(:D), rhs_terms)
    rhs_beta = isempty(xvars_beta) ? ConstantTerm(1) : sum(xvars_beta)
    fml_beta = term(:Y) ~ rhs_beta + sum(fe_terms)

    if type == "fdS"
        dat_regression_beta = dat[dat[:, :weights] .!= 0, :]
        beta_lm = FixedEffectModels.reg(dat_regression_beta, fml_beta, weights = :weights, save = :none)
    else
        beta_lm = FixedEffectModels.reg(dat, fml_beta, weights = :weights)
    end
    beta = coef(beta_lm)[coefnames(beta_lm) .== "D"][1]

    # Type-specific weight calculations

    if type == "feTR"

        eps_vec = dat[!, EPS_VAR]
        D_vec = dat[!, DVAR]
        denom_W = weighted_mean(eps_vec .* D_vec, dat[!, :weights])
    
        DataFrames.transform!(dat, EPS_VAR => ((x) -> x .* mean_D / denom_W) => :W)
        DataFrames.transform!(dat, [:W, :nat_weight] => ((x, y) -> x .* y) => :weight_result)

        if !isnothing(treatments)
            for treatment in vcat(treatments)
                varname = fn_treatment_weight_rename(treatment)
                dat[:, Symbol(varname)] = dat[:, :W] .* dat[:, :P_gt] .* dat[:, Symbol(treatment)] ./ mean_D
            end
        end

        # Cleanup
        dat = dat[:, Not(Symbol(EPS_VAR), "P_gt")]
        
        # Only keeping one observation per group:
        dat = combine(groupby(dat, [:G, :Tfactor]), first)
        
    elseif type == "feS"

        DataFrames.sort!(dat, [:G, :Tfactor])
        eps_w = dat[:, EPS_VAR] .* dat[:, :weights]
        g_int = Int.(dat[!, :G])
        
        # To implement
        E_eps_1_g_ge_aux        = rev_cumsum_by_group(g_int, eps_w) 
        weights_aux             = rev_cumsum_by_group(g_int, dat[:, :weights])
        E_eps_1_g_ge            = E_eps_1_g_ge_aux / weights_aux
        dat[:, :E_eps_1_g_ge]   .= E_eps_1_g_ge
    
    elseif type == "fdTR"
        
        dat[:, :eps_2] = ifelse.(.!ismissing(dat[:, Symbol(EPS_VAR)]), dat[:, Symbol(EPS_VAR)], 0)
    
    end

    # Post-beta calculations per type

    if type == "fdTR"
        DataFrames.sort!(dat, [:G, :TfactorNum])
        g_int = Int.(dat[!, :G])
        # To implement
        w_tilde_2 = fdtr_wtilde2(
            d_int,
            dat[!, :TFactorNum],
            eps_2 = dat[!, :eps_2],
            P_gt = dat[!, :P_gt])
        dat[:, :w_tilde_2] .= w_tilde_2

        DataFrames.transform!(
            dat,
            [:w_tilde_2 :D0] => ((x, y) -> x .* y) => :w_tilde_2_E_D_gt)
        denom_W = weighted_mean(dat.w_tilde_2_E_D_gt, dat.P_gt)
        DataFrames.transform!(dat, [:w_tilde_2, :mean_D] => ((x, y) -> x .* y / denom_W) => :W)
        DataFrames.transform!(dat, [:W, :nat_weight] => ((x, y) -> x .* y) => :weight_result)

        # Cleanup
        dat = dat[:, Not(:eps_2, :P_gt, :w_tilde_2, :w_tilde_2_ED_gt)]
    
    elseif type == "feS"

        DataFrames.sort!(dat, [:G, :TfactorNum])
        g_int = Int.(dat[!, :G])
        # To implement
        delta_res = feS_delta(g_int, dat[!, :TFactorNum], dat[!, :D], P_gt = dat[!, :P_gt])
        
        # Here are some notes for future references: 
        # DataFrames.filter((x -> !ismissing(x.delta_D)), gdat) # Runs, but does not eliminate the missing values rows.
        # This is because the !ismissing function runs on groups, and not on rows.
        # We can just change the underlying dat dataframe, s.t.:
        # dropmissing!(dat, :delta_D)
        keep    = delta_res[!, :keep]
        dat     = dat[!, keep]
        delta_D         = delta_res[keep, :delta_D]
        s_gt            = delta_res[keep, :s_gt]
        abs_delta_D     = delta_res[keep, :abs_delta_D]
        nat_w           = delta_res[keep, :nat_weight]

        delta_res[!, :delta_D]      = delta_D
        delta_res[!, :s_gt]         = s_gt
        delta_res[!, :abs_delta_D]  = abs_delta_D
        delta_res[!, :nat_w]        = nat_w
        
        P_S = sum(skipmissing(nat_w))        
        DataFrames.transform!(dat, [:nat_weight, :P_S] => ((x, y) -> x ./ y) => :nat_weight)
        DataFrames.transform!(dat, [:s_gt, :E_eps_1_g_ge, :P_gt] => ((x, y, z) -> x .* y ./ z) => :om_tilde_1)

        denom_W = weighted_mean(dat.om_tilde_1, dat.nat_weight)
        DataFrames.transform!(dat, :om_tilde_1 => (x -> x ./ denom_W) => :W)
        DataFrames.transform!(dat, [:W, :nat_weight] => ((x, y) -> x .* y) => :weight_result)

        dat = dat[:, Not(:eps_1, :P_gt, :om_tilde_1, :E_eps_1_g_ge, :abs_delta_D, :delta_D)]
    
    elseif type =="fdS"

        DataFrames.transform!(dat, :D => (x -> ifelse.(x .> 0, 1, ifelse.(x .< 0, -1, 0))) => :s_gt)
        DataFrames.transform!(dat, :D => (x -> abs.(x)) => :abs_delta_D)
        DataFrames.transform!(dat, [:P_gt, :abs_delta_D] => ((x, y) -> x .* y) => :nat_weight)
    
        P_S = sum(dat.nat_weight)
        
        DataFrames.transform!(dat, :nat_weight => (x -> x ./ P_S) => :nat_weight)
        DataFrames.transform!(dat, [:s_gt, :eps_2] => ((x, y) -> x .* y) => :W)
        
        denom_W = weighted_mean(dat.W, dat.nat_weight)

        DataFrames.transform!(dat, :W => (x -> x ./ denom_W) => :W)
        DataFrames.transform!(dat, [:W, :nat_weight] => ((x, y) -> x .* y) => :weight_result)

        dat = dat[:, Not(:eps_2, :P_gt, :abs_delta_D)]
    end
    
    # Reordering
    main_columns = ["Y", "G", "T", "D"]
    other_columns = filter(c -> c ∉ main_columns, names(dat))
    dat = dat[:, vcat(main_columns, other_columns)]

    return OrderedCollections.OrderedDict(:dat => dat, :beta => beta)

end