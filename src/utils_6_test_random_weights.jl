# This file defines the twowayfeweights_test_random_weights function, which computes the test ratio based on the weights.
# It defines several methods, one for Vector{Union{Nothing, String}}, one for Vector{String}, and one for String.

"""
    twowayfeweights_test_random_weights

    Vector{Union{Nothing, String}} method

"""
function twowayfeweights_test_random_weights(;
    df::DataFrames.DataFrame,
    random_weights::Vector{Union{Nothing, String}})

    if !isnothing(random_weights)
        if(typeof(random_weights)) == Vector{String}
            mat = DataFrames.DataFrame(zeros(length(random_weights), 4), :auto)
        elseif typeof(random_weights) == String
            mat = DataFrames.DataFrame(zeros(length([random_weights]), 4), :auto)
        end
    else 
        mat = DataFrames.DataFrame(zeros(0, 4), :auto)
    end
    rename!(mat, ["Coef", "SE", "t-stat", "Correlation"])
    df_filtered = df[isfinite.(df[:, :W]), :]

    if !isnothing(random_weights)
        for vv in 1:length([random_weights])

            v = [random_weights][vv]

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
    end

    return mat

end

"""
    twowayfeweights_test_random_weights

    Vector{String} method

"""
function twowayfeweights_test_random_weights(;
    df::DataFrames.DataFrame,
    random_weights::Vector{String})

    mat = DataFrames.DataFrame(zeros(length(random_weights), 4), :auto)

    rename!(mat, ["Coef", "SE", "t-stat", "Correlation"])
    df_filtered = df[isfinite.(df[:, :W]), :]

    for vv in 1:length(random_weights)

        v = [random_weights][vv]

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

"""
    twowayfeweights_test_random_weights

    String method

"""
function twowayfeweights_test_random_weights(;
    df::DataFrames.DataFrame,
    random_weights::String)

    mat = DataFrames.DataFrame(zeros(length([random_weights]), 4), :auto)

    rename!(mat, ["Coef", "SE", "t-stat", "Correlation"])
    df_filtered = df[isfinite.(df[:, :W]), :]

    for vv in 1:length([random_weights])

        v = [random_weights][vv]

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