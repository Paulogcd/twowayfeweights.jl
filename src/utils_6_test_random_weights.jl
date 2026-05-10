"""
    twowayfeweights_test_random_weights



"""
function twowayfeweights_test_random_weights(;
    df::DataFrames.DataFrame,
    random_weights::Vector{String})

    mat = DataFrames.DataFrame(zeros(length(random_weights), 4), :auto)
    rename!(mat, ["Coef", "SE", "t-stat", "Correlation"])
    df_filtered = df[isfinite.(df[:, :W]), :]

    # To check if this is an issue in Julia
    #   df_filtered_sub <- subset(df_filtered, df_filtered$nat_weight != 0) #Modif. Diego: added extra line to solve note in R CMD Check

    # random_weights = "random_weights"

    for vv in 1:length(random_weights)

        v = random_weights[vv]

        formule = Term(Symbol(v)) ~ Term(:W)
        rw_lm = FixedEffectModels.reg(df_filtered, formule, weights = :nat_weight, Vcov.cluster(:G));

        # Here, the use of "[coefnames(rw_lm) .== "W"]" seems a bit cumbersome.
        # There is maybe a clearer way to refer to the W coef.
        beta = only(coef(rw_lm)[coefnames(rw_lm) .== "W"])
        se = only(sqrt.(LinearAlgebra.diag(vcov(rw_lm)))[coefnames(rw_lm) .== "W"]) # Is there another way?
        r2 = FixedEffectModels.r2(rw_lm)

        mat[vv, :Coef]  = beta
        mat[vv, :SE]    = se
        mat[vv, Symbol("t-stat")] = beta/se

        if beta > 0 
            to_add = sqrt(r2)
        else
            to_add = -sqrt(r2)
        end
        
        mat[vv, end] = to_add
    
    end

    return mat

end
# This function seems to call objects of the environment in which it is called.
# I will let its finition to later, when I have more comprehension of the context in which it is called.