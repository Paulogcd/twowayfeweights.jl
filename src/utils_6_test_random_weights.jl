"""
    twowayfeweights_test_random_weights

    Union{String, Vector{String}} method

"""
function twowayfeweights_test_random_weights(;
    df::DataFrames.DataFrame,
    random_weights::Union{String, Vector{String}})

    if typeof(random_weights) == String
        random_weights = [random_weights]
    end

    mat = DataFrames.DataFrame(zeros(length(random_weights), 4), :auto)
    rename!(mat, ["Coef", "SE", "t-stat", "Correlation"])
    df_filtered = df[isfinite.(df[:, :W]), :]
    df_filtered_sub = df_filtered[df_filtered[:, :nat_weight] .!= 0, :]

    if !isnothing(random_weights)
        for vv in 1:length(random_weights)

            v = getindex(random_weights, vv)

            formule = Term(Symbol(v)) ~ Term(:W)
            rw_lm = FixedEffectModels.reg(df_filtered_sub, formule, weights = :nat_weight, Vcov.cluster(:G));

            # Here, the use of "[coefnames(rw_lm) .== "W"]" seems a bit cumbersome.
            # There is maybe a clearer way to refer to the W coef.
            beta = only(coef(rw_lm)[coefnames(rw_lm) .== "W"])
            # The following computation is slightly (10^-4) different from what is given in the original R package.
            # A priori, this seems to linked to the solver difference?
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
    end

    return mat

end