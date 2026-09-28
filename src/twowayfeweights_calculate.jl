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

        # Earlier version:
        # rhs_terms = map(xvars) do x
        #     x == "1" ? ConstantTerm(1) : term(Symbol(x))
        # end
        # if length(xvars) == 1
        #     rhs = rhs_terms
        # else
        #     rhs = foldl(+, rhs_terms)
        # end
        # # fixed effects
        # fes_vec = isa(fes, AbstractString) ? [fes] : fes
        # fe_terms = foldl(+, fe.(term.(Symbol.(fes_vec))))
        # # full formula
        # if rhs == [term(Symbol(1))]
        #     ff = term(:D) ~ ConstantTerm(1) + fe_terms
        # else
        #     ff = term(:D) ~ rhs + fe_terms
        # end
        # denom_lm = reg(dat, ff, weights = :weights, save = :residuals)
    
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
    beta = coef(beta_lm)[coefnames(beta_lm) .== "D"]

    # Type-specific weight calculations

    if type == "feTR"

        eps_vec = dat[!, EPS_VAR]
        D_vec = dat[!, DVAR]
        denom_W = weighted_mean(eps_vec .* D_vec, dat[!, :weights])
    
        DataFrames.transform!(
            dat,
            EPS_VAR => ((x) -> x * mean_D / denom_W) => :W
        )

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

    # New regression
    # push!(xvars, Term(Symbol("D")))
    xvars = vcat(xvars, Term(Symbol("D")))

    if type == "fdS"
        
        dat_regression = dat[dat[:, :weights] .!= 0, :]

        # Regressors in xvars
        rhs = foldl(+, xvars)

        # fixed effects
        fes_vec = isa(fes, AbstractString) ? [fes] : fes
        fe_terms = foldl(+, fe.(term.(Symbol.(fes_vec))))
        
        # full formula
        ff = term(:Y) ~ rhs + fe_terms

        beta_lm = FixedEffectModels.reg(dat_regression, ff, weights = :weights, save = :all)
        # In Julia: 0.060095972248468944
        # In R:     0.06009597224846937452147

        # The original regression was: 
        # beta.lm = feols(Y ~ .[xvars] | .[fes], data = subset(dat, weights != 0), weights = dat$weights, only.coef = TRUE)

    else
        
        rhs_terms = map(xvars) do x
            x == ConstantTerm(1) ? ConstantTerm(1) : term(Symbol(x))
        end
        rhs = foldl(+, rhs_terms)

        # fixed effects
        fes_vec = isa(fes, AbstractString) ? [fes] : fes
        fe_terms = foldl(+, fe.(term.(Symbol.(fes_vec))))
        
        # full formula
        ff = term(:Y) ~ rhs + fe_terms

        beta_lm = reg(dat, ff, weights = :weights, save = :residuals)
    end
    
    # Is there a better way to select the beta of the D variable?
    beta = only(coef(beta_lm)[coefnames(beta_lm) .== "D"])
    
    if type == "feTR"
        # Original comment:
        # * Keeping only one observation in each group * period cell
        # This should be done after this function
        # bys `group' `time': gen group_period_unit=(_n==1)	
        # 	drop if group_period_unit==0
        # 	drop group_period_unit
        gdat = DataFrames.groupby(dat, [:G, :Tfactor])
        dat = combine(gdat) do sdf
            sdf[argmin(sdf.D), :] # This seems off, as we are already using a dataframe with only one observation per G * T
        end
        # gdat = groupby(dat, [:G, :Tfactor])
        # dat = combine(gdat) do sdf
        #     sdf[1, :]
        # end
        # dat = combine(groupby(dat, [:G, :Tfactor]), first)


    elseif type == "fdTR"
        
        dat = DataFrames.sort(dat, [:G, :TFactorNum])
        gdat = DataFrames.groupby(dat, [:G])
        
        DataFrames.transform!(
            dat,
            [:TFactorNum, :eps_2, :P_gt] => ((x, y, z) -> (ifelse.(ifelse.(ismissing.(x .+ 1 .== lead(x)), false, x .+ 1 .== lead(x)), (y - lead(y) .* lead(z) ./ z), missing))) => :w_tilde_2
        )

        DataFrames.transform!(
            dat,
            [:w_tilde_2, :eps_2] =>
                ((x, y) -> map((a, b) -> (!ismissing(a) && isfinite(a)) ? a : b, x, y)) =>
                :w_tilde_2
        )

        DataFrames.transform!(
            dat,
            [:w_tilde_2, :D0] => ((x, y) -> x .* y) => :w_tilde_2_E_D_gt
        )

        # denom_W = weighted_mean(x = dat.w_tilde_2_E_D_gt, w = dat.P_gt)
        denom_W = weighted_mean(dat.w_tilde_2_E_D_gt, dat.P_gt)
        DataFrames.transform!(
            dat,
            :w_tilde_2 => (x -> (x .* mean_D ./ denom_W)) => :W
        )
        DataFrames.transform!(
            dat,
            [:W, :nat_weight] => ((x, y) -> x .* y) => :weight_result)
    
        dat = dat[:, Not(:eps_2, :P_gt, :w_tilde_2, :w_tilde_2_E_D_gt)]
    
    elseif type == "feS"

        # To test with a dataframe that supports the operation, with the correct columns.
        # Also, re-write so that it uses transform(groupby.., col1, col2, etc...)

        dat = DataFrames.sort(dat, [:G, :Tfactor])
        gdat = DataFrames.groupby(dat, [:G])
        
        DataFrames.transform!(gdat,
            [:TFactorNum, :D] =>
                ((t, d) ->
                    ifelse.(
                        coalesce.(t .- 1 .== ShiftedArrays.lag(t), false), # Make the TFactorNum correct to test this.
                        d .- ShiftedArrays.lag(d),
                        missing
                    )
                ) => :delta_D,
        )
        
        # Here are some notes for future references: 
        # DataFrames.filter((x -> !ismissing(x.delta_D)), gdat) # Runs, but does not eliminate the missing values rows.
        # This is because the !ismissing function runs on groups, and not on rows.
        # We can just change the underlying dat dataframe, s.t.:        
        dropmissing!(dat, :delta_D)

        # dat = gdat[(.!ismissing.(gdat.delta_D)), :]
        DataFrames.transform!(dat, :delta_D => (x -> abs.(x)) => :abs_delta_D)
        # dat.abs_delta_D = abs.(dat.delta_D)
        
        # The dplyr::case_when function can be replicated using the ternary syntax, mentioned here: 
        # https://bkamins.github.io/julialang/2020/12/18/casewhen.html
        # For the whole thread, see: 
        # https://discourse.julialang.org/t/case-when-style-operation-on-dataframes/63414/7
        # One could also think of the ifelse solution proposed by Nils HG.
        # In fact, refer to: 
        # https://discourse.julialang.org/t/ternary-operator-on-a-dataframe/102798/8
        dat.s_gt = ifelse.(dat.delta_D .> 0, 1, ifelse.(dat.delta_D .< 0, -1, 0))
        dat.nat_weight = dat.P_gt .* dat.abs_delta_D
        
        dat.P_S .= sum(dat.nat_weight)
        DataFrames.transform!(dat, [:nat_weight, :P_S] => ((x, y) -> x ./ y) => :nat_weight)
        DataFrames.transform!(dat, [:s_gt, :E_eps_1_g_ge, :P_gt] => ((x, y, z) -> x .* y ./ z) => :om_tilde_1)
 
        # denom_W = weighted_mean(x = dat.om_tilde_1, w = dat.nat_weight)
        denom_W = weighted_mean(dat.om_tilde_1, dat.nat_weight)

        DataFrames.transform!(dat, :om_tilde_1 => (x -> x ./ denom_W) => :W)
        DataFrames.transform!(dat, [:W, :nat_weight] => ((x, y) -> x .* y) => :weight_result)

        dat = dat[:, Not(:eps_1, :P_gt, :om_tilde_1, :E_eps_1_g_ge, :E_eps_1_g_ge_aux, :weights_aux, :abs_delta_D, :delta_D)]
    
    elseif type =="fdS"

        DataFrames.transform!(
            dat, 
            :D => (x -> ifelse.(x .> 0, 1, ifelse.(x .< 0, -1, 0))) => :s_gt,
        )
        # mean(dat.s_gt)
        # Julia: 0.0015727391874180866
        # R: 0.001572739187417914819359

        DataFrames.transform!(
            dat, :D => (x -> abs.(x)) => :abs_delta_D
        )
        # mean(dat.abs_delta_D) 
        # Julia:    0.05976409f0
        # R:        0.05976408912188731908932

        DataFrames.transform!(
            dat,
            [:P_gt, :abs_delta_D] => ((x, y) -> x .* y) => :nat_weight
        )
        # mean(dat.nat_weight)
        # Julia:    1.566555416038985e-5
        # R:        1.566555416038984790603e-05
    
        P_S = sum(dat.nat_weight)
        # Julia:    0.059764089121887284
        # R:        0.05976408912188742317273
    
        DataFrames.transform!(
            dat,
            :nat_weight => (x -> x ./ P_S) => :nat_weight,
        )
        # mean(dat.nat_weight)
        # Julia:  0.0002621231979030144
        # R:      0.0002621231979030134323118

        # dat.nat_weight

        DataFrames.transform!(
            dat,    
            [:s_gt, :eps_2] => ((x, y) -> x .* y) => :W
        )
        # mean(dat.W)
        # Julia:  0.059266776485865785
        # R:      0.05926677648586579222334
        
        # denom_W = weighted_mean(x = dat.W, w = dat.nat_weight)
        denom_W = weighted_mean(dat.W, dat.nat_weight)
        # Julia:  0.9916787381297281
        # R:      0.9916787381297236247946

        DataFrames.transform!(
            dat,
            :W => (x -> x ./ denom_W) => :W
        )

        DataFrames.transform!(
            dat,
            [:W, :nat_weight] => ((x, y) -> x .* y) => :weight_result
        )
        # mean(dat.weight_result)
        # 0.0002599420021309903
        # 0.0002621231979030147333544

        dat = dat[:, Not(:eps_2, :P_gt, :abs_delta_D)]
    end
    
    # Reordering
    main_columns = ["Y", "G", "T", "D"]
    other_columns = filter(c -> c ∉ main_columns, names(dat))
    dat = dat[:, vcat(main_columns, other_columns)]
    # dat = dat[:, Not(:eps_1_E_D_gt)]

    return OrderedCollections.OrderedDict(:dat => dat, :beta => beta)

end