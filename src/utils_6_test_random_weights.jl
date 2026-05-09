"""
    twowayfeweights_test_random_weights



"""
function twowayfeweights_test_random_weights(;
    df::DataFrames.DataFrame,
    random_weights::Union{String, Vector{String}})

    mat = DataFrames.DataFrame(Matrix{Union{Missing, String}}(missing, 0, 4), :auto)
    rename!(mat, ["Coef", "SE", "t-stat", "Correlation"])

    df_filtered = df[isfinite.(df[:, :W]), :]

    # To check if this is an issue in Julia
    #   df_filtered_sub <- subset(df_filtered, df_filtered$nat_weight != 0) #Modif. Diego: added extra line to solve note in R CMD Check

    random_weights = "random_weights"

#   for (v in random_weights) {
    for v in random_weights
        formula = formula::FormulaTerm(sprint("%s ~ W", v))
        ff = formula::FormulaTerm($(v) ~ W)
        @formula(v ~ W)
        ff = @eval @formula($(v) ~ W)
        rw.lm = feols
        FixedEffectModels.reg(df, formula)
        methods(FixedEffectModels.reg)

#     rw_lm = fixest::feols(fml = as.formula(formula), data = df_filtered_sub, weights = ~nat_weight, vcov = ~G)
#     beta = stats::coef(rw_lm)[["W"]]
#     se = sqrt(diag(stats::vcov(rw_lm)))[["W"]]
#     r2 = fixest::r2(rw_lm)["r2"]
#     
#     mat[v, ] <- c(beta, se, beta/se, if (beta > 0) { sqrt(r2) } else { -sqrt(r2) })
#   }
#   
    end

    return mat

end
# This function seems to call objects of the environment in which it is called.
# I will let its finition to later, when I have more comprehension of the context in which it is called.