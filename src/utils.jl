# This document is dedicated to the replication of the utils file 
# of the original package. 


""" 
    fn_ctrl_rename(x)

Rename variables by writing "ctrl_" at their beginning.
The `fn_ctrl_rename` function is the equivalent of the original `fn_ctrl_rename` function, defined in the original R code such as: 
    fn_ctrl_rename <- function(x) paste("ctrl", x, sep="_")

# Examples
```jldoctest
julia> x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4

julia> fn_ctrl_rename(x)
4-element Vector{String}:
 "ctrl1_"
 "ctrl2_"
 "ctrl3_"
 "ctrl4_"
```
"""
function fn_ctrl_rename(x)

    x = string.(x)
    result = "ctrl_" .* x # How does it compare to the simple "string.("ctrl_", x)"?

    return(result)
end
# x = [1,2,3,4]
# fn_ctrl_rename(x)
# ?fn_ctrl_rename

"""
    get_controls_rename(controls)

Rename a vector of variable names by writing "ctrl_" in front of them.
The `get_controls_rename` function is the equivalent of the original `get_controls_rename` function, defined in the original R code as: 
    get_controls_rename <- function(controls) unlist(lapply(controls, fn_ctrl_rename))

```jldoctest
julia> x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4

julia> fn_ctrl_rename(x)
4-element Vector{String}:
 "ctrl1_"
 "ctrl2_"
 "ctrl3_"
 "ctrl4_"
```

"""
function get_controls_rename(controls)
    result = fn_ctrl_rename.(controls)
    # result = unlist(result) ? (equivalent) ? 

    return(result)
end
# x = [1,2,3,4]
# get_controls_rename(x)
# ?get_controls_rename()

"""
    fn_treatment_rename(x)

Rename a variable by writing "OT_" in front of it.
The `fn_treatment_rename` function is the equivalent of the original `get_controls_rename` function, defined in the original R code such as: 
        fn_treatment_rename <- function(x) paste("OT", x, sep="_")
"""
function fn_treatment_rename(x)
    
    x = string.(x)
    result = "OT_" .* x

    return(result)
end

# get_treatments_rename <- function(treatments) {unlist(lapply(treatments, fn_treatment_rename))}
"""
    get_treatments_rename(treatments)

Rename a vector of variables by putting "OT_" in front of them.
The `get_treatments_rename` function is the equivalent of the original `get_treatments_rename` function, defined in the original R code such as: 
    get_treatments_rename <- function(treatments) {unlist(lapply(treatments, fn_treatment_rename))}

```jldoctest
julia> x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4

julia> get_treatments_rename(x)
4-element Vector{String}:
 "OT_1"
 "OT_2"
 "OT_3"
 "OT_4"
```
"""
function get_treatments_rename(treatments)
    result = fn_treatment_rename.(treatments)
    # result = unlis(result) # ? equivalent ?
    return(result)
end
# x = [1,2,3,4]
# get_treatments_rename(x)

"""
    fn_treatment_weight_rename(x)

Rename a vector of variables by putting "weight_" in front of them.
The `fn_treatment_weight_rename` function is the equivalent of the original `fn_treatment_weight_rename` function, defined in the original R code such as: 
    fn_treatment_weight_rename <- function(x) paste("weight_", x, sep = "")

```jldoctest
julia> x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4
julia> fn_treatment_weight_rename(x)
4-element Vector{String}:
 "weight_1"
 "weight_2"
 "weight_3"
 "weight_4"
````
"""
function fn_treatment_weight_rename(x)
    x = string.(x)
    result = "weight_" .* x
    return(result)
end


"""
    fn_treatment_weight_rename(x)

Rename a vector of variables by putting "RW_" in front of them.
The `fn_random_weight_rename` function is the equivalent of the original `fn_random_weight_rename` function, defined in the original R code such as: 
    fn_random_weight_rename <- function(x) paste("RW", x, sep="_")

```jldoctest
julia> x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4
julia> fn_treatment_weight_rename(x)
4-element Vector{String}:
 "RW_1"
 "RW_2"
 "RW_3"
 "RW_4"
```
"""
function fn_random_weight_rename(x)
    x = string.(x)
    result = "RW_" .* x
    return(result)
end

"""
    get_random_weight_rename(x)

Rename a vector of variables by putting "RW_" in front of them.
The `fn_random_weight_rename` function is the equivalent of the original `fn_random_weight_rename` function, defined in the original R code such as: 
    # get_random_weight_rename <- function(ws) unlist(lapply(ws, fn_random_weight_rename))

```jldoctest
julia> x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4
julia> fn_treatment_weight_rename(x)
4-element Vector{String}:
 "RW_1"
 "RW_2"
 "RW_3"
 "RW_4"
```
"""
function get_random_weight_rename(ws)
    ws = string.(ws)
    result = fn_random_weight_rename(ws) # unlist equivalent ? 
    return(result)
end

"""
    twowayfeweights_rename_var(df, Y, G, T, D, D0, controls, treatments, random_weights)
Rename variables according to the control, random_weight, syntax, in a dataframe.
"""
function twowayfeweights_rename_var(;df::DataFrames.DataFrame, Y, G, T, D, D0, controls, treatments, random_weights)
    # twowayfeweights_rename_var <- function(df, Y, G, T, D, D0, controls, treatments, random_weights) {

    # controls = ["age", "date", "weather"]
    # treatments = ["money"]
    
    # controls_rename <- get_controls_rename(controls)
    # treatments_rename <- get_treatments_rename(treatments)
    controls_rename     = get_controls_rename(controls)
    treatments_rename   = get_treatments_rename(treatments)
  
    # if (length(random_weights) > 0) {
    #     random_weight_rename <- get_random_weight_rename(random_weights)
    #     random_weight_df <- df[, random_weights, drop = FALSE]
    #     # random_weight_df <- df %>% dplyr::select(all_off(random_weights))
    #     colnames(random_weight_df) <- random_weight_rename
    # }
    # Testing with values: 
    # random_weights = ["random_weights_1",
    #                     "random_weights_2",
    #                     "random_weights_3",
    #                     "random_weights_4"]
    # df = DataFrames.DataFrame(random_weights_1 = [1,2,3], 
    #                             random_weights_2 = [1,2,3], 
    #                             random_weights_3 = [1,2,3], 
    #                             random_weights_4 = [1,2,3])
    
    # If there is any random weight variables, rename them with "weights_" in front of their names.
    if length(random_weights) > 0
        random_weight_rename = get_random_weight_rename(random_weights)
        # random_weight_df = DataFrames.DataFrame(df[:, random_weights]) # ? 
        random_weight_df = select(df, random_weights) # ? 
        rename!(random_weight_df, random_weights => random_weight_rename)
    end
    
    # original_names = c(Y, G, T, D, controls, treatments)
    original_names = [Y, G, T, D, controls, treatments]
    # new_names = c("Y", "G", "T", "D", controls_rename, treatments_rename)
    new_names = ["Y", "G", "T", "D", controls_rename, treatments_rename]
    
    # if (!is.null(D0)) {
    #     original_names = c(original_names, D0)
    #     new_names = c(new_names, "D0")
    # }
    # D0 = ["this"]
    if length(D0) > 0 
        original_names  = vcat(original_names, D0)
        new_names       = vcat(new_names, "D0")
        # new_names = append!(new_names, "D0")
    end
    
    # df <- data.frame(df) %>% dplyr::select_at(dplyr::vars(original_names))
    df = DataFrames.DataFrame(
        df[:, original_names]
    )
         # ? 
    # colnames(df) <- new_names
    DataFrames.rename!(df, new_names) # to be tested <=> "?"
    
    # if (length(random_weights) > 0) {
    #     df <- cbind(df, random_weight_df)
    # }
    if length(random_weights) > 0 
        df = hcat(df, random_weight_df)
    end
    
    # return(df)
    return df
# }
end

# twowayfeweights_transform <- function(df, controls, weights, treatments) {
function twowayfeweights_transform(;df::DataFrames.DataFrame, controls, weights, treatments)

#   .data = NULL # This is done to modify the default .data of dplyr functions.
#   data = []
#
#   ret = twowayfeweights_normalize_var(df, "D")
    # No former definition of twowayfeweights_normalize_var, 
    # go check the file "twowayfeweights_normalize_var.jl"
    ret = twowayfeweights_normalize_var(df = df, varname = "D") 

#   if (ret$retcode) {
    if ret[:retcode] # if ret is a list, we can use "." instead of "$"
#     df <- ret$df
        df = ret[:df]
        print("The treatment variable in the regression varies within some group * period cells.")
        print("The treatment variable in the regression varies within some group * period cells.")
        print("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
        print("with a group * period level treatment.")
        print("The command will replace the treatment by its average value in each group * period.")
        print("The results below apply to the two-way fixed effects regression with that treatment variable.")
#   }
    end
#   
#   for (control in controls) {
    for control in controls
#     ret = twowayfeweights_normalize_var(df, control)
        ret = twowayfeweights_normalize_var(df = df, varname = control)
#     if (ret$retcode) {
        if ret[:retcode]
            df = ret[:df]
            print("The control variable %s in the regression varies within some group * period cells.", control)
            print("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
            print("with controls apply to group * period level controls.")
            print("The command will replace replace control variable %s by its average value in each group * period.", control)
            print("The results below apply to the regression with control variable %s averaged at the group * period level.", control)
#       df <- ret$df
#       printf("The control variable %s in the regression varies within some group * period cells.", control)
#       printf("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
#       printf("with controls apply to group * period level controls.")
#       printf("The command will replace replace control variable %s by its average value in each group * period.", control)
#       printf("The results below apply to the regression with control variable %s averaged at the group * period level.", control)
#     }
#   }
        end
    end
#   
#   for (treatment in treatments) {
    for treatment in treatments
#     ret = twowayfeweights_normalize_var(df, treatment)
        ret = twowayfeweights_normalize_var(df = df, varname = treatment)
#     if (ret$retcode) {
        if ret[:retcode]
#           df <- ret$df
            df = ret[:df]
            print("The other treatment variable %s in the regression varies within some group * period cells.", treatment)
            print("The results in de Chaisemartin, C. and D'Haultfoeuille, X. (2020) apply to two-way fixed effects regressions")
            print("with several treatments apply to group * period level controls.")
            print("The command will replace replace other treatment variable %s by its average value in each group * period.", treatment)
            print("The results below apply to the regression with other treatment variable %s averaged at the group * period level.", treatment)
    #     }
        end
#   }
    end
#   
#   if (is.null(weights)) {
    if weights == [] # possible equivalent for is.null in R?
#     df$weights <- 1
        df.weights = 1
#   } else {
    else 
        df.weights = repeat(weights, nrow(df))
    end
#     df$weights <- weights
#   }
#   
#   df$Tfactor <- factor(df$T)
    df.Tfactor = CategoricalArrays.categorical(string.(df.T))
    # CategoricalArrays.levels(df.T)
#   TfactorLevels <- length(levels(df$Tfactor))
    # TfactorLevels = length(CategoricalArrays.levels(df.Tfactor)) # ¿What is the goal of this line?
#   df <- df %>% dplyr::mutate(TFactorNum = as.numeric(factor(.data$Tfactor, labels = seq(1:TfactorLevels))))
    df.TFactorNum = Int64.(df.T)
#   
#   return(df)
    return df
# }
end

# # twowayfeweights_filter
# twowayfeweights_filter <- function(df, Y, G, T, D, D0, cmd_type, controls, treatments) {
function twowayfeweights_filter(df, Y, G, T, D, D0, cmd_type, controls, treatments)
#   .data = NULL
    data = []
#   # Remove rows with NA values
#   if (cmd_type != "fdTR") { 
    if(cmd_type != "fdTR") #? What is this class?
#     df <- df %>%
#       dplyr::mutate(tag = rowSums(dplyr::across(.cols = c(Y, G, T, D, controls, treatments), .fns = is.na))) %>%
#       dplyr::filter(.data$tag == 0) %>%
#       dplyr::select(-.data$tag)
        gdf = DataFrames.transform(
            DataFrames.groupby(df,
                [:Y,:G,:T,:D,:controls,:treatments]), 
            
        )
#   } else {
    else
#     df <- df %>%
#       dplyr::mutate(tag1 = rowSums(dplyr::across(.cols = c(D, T, Y), .fns = is.na))) %>%
#       dplyr::mutate(tag2 = rowSums(dplyr::across(.cols = c(D0), .fns = is.na))) %>%
#       dplyr::filter(.data$tag1 == 0 | .data$tag2 == 0)
#     
#     if (length(controls) > 0) {
#       df <- df %>%
#         dplyr::mutate(tag3 = rowSums(dplyr::across(.cols = controls, .fns = is.na))) %>%
#         dplyr::filter(.data$tag1 == 1 | .data$tag3 == 0) %>%
#         dplyr::select(-.data$tag3)
#     }
#     df <- df %>% dplyr::select(-.data$tag1, -.data$tag2)
    end
        df = df[:,Not(data.tag1, data.tag2)]
#   }
#   return(df)
    return df
# }
end

# ##
# # twowayfeweights_summarize_weights
# twowayfeweights_summarize_weights <- function(df, var_weight) {
function twowayfeweights_summarize_weights(df, var_weight)
#   weight_plus <- df[[var_weight]][df[[var_weight]] > 0 & !is.na(df[[var_weight]])] # What is this condition?
    weight_plus = df[[var_weight]][df[[var_weight]] > 0 &&  is.equal(df[[var_weight]], NaN)] # ? 
#   nr_plus <- length(weight_plus)
    nr_plus = length(weight_plus)
#   sum_plus <- sum(weight_plus, na.rm = TRUE)
    # !isnan(x) = isnan(x) == 1 ? 0 : 1 # To see if we use NaN or missing.

    weight_plus != weight_plus[isnan.(weight_plus)]
    sum_plus = sum(weight_plus)#, na.rm = TRUE)
    isnan.(weight_plus)
#   
#   weight_minus <- df[[var_weight]][df[[var_weight]] < 0 & !is.na(df[[var_weight]])] #? What is this Condition?
#   nr_minus <- length(weight_minus)
    nr_minus = length(weight_minus)
#   sum_minus <- sum(weight_minus, na.rm = TRUE)
#   
#   nr_weights <- nr_plus + nr_minus
    nr_weights = nr_plus + nr_minus
#   
    result = (;
        nr_plus    = nr_plus,
       nr_minus   = nr_minus,
       nr_weights = nr_weights,
       sum_plus   = sum_plus,
       sum_minus  = sum_minus)
#   return(
#     list(
#       nr_plus    = nr_plus,
#       nr_minus   = nr_minus,
#       nr_weights = nr_weights,
#       sum_plus   = sum_plus,
#       sum_minus  = sum_minus
#     )
#   )
    return result
# 
# }
end

# ##
# # twowayfeweights_test_random_weights
# twowayfeweights_test_random_weights <- function(df, random_weights) {
function twowayfeweights_test_random_weights(df, random_weights)
    data = []
#   
#   .data = NULL
#   
#   mat <- data.frame(matrix(nrow = 0, ncol = 4))
    mat = DataFrames.DataFrame(Matrix{Union{Missing, String}}(missing, 0, 4), :auto)
#   colnames(mat) <- c("Coef", "SE", "t-stat", "Correlation")
    rename!(mat, ["Coef", "SE", "t-stat", "Correlation"])
#   df_filtered <- df %>% dplyr::filter(is.finite(.data$W))
#   df_filtered_sub <- subset(df_filtered, df_filtered$nat_weight != 0) #Modif. Diego: added extra line to solve note in R CMD Check
#  
#   for (v in random_weights) {
#     formula <- sprintf("%s ~ W", v)
#     # rw.lm = estimatr::lm_robust(formula = as.formula(formula), data = df_filtered_sub, weights = df_filtered_sub$nat_weight, clusters = df_filtered_sub$G, se_type = "stata")
#     # beta <- rw.lm$coefficients[["W"]]
#     # se <- rw.lm$std.error[["W"]]
#     # r2 <- rw.lm$r.squared
#     rw_lm = fixest::feols(fml = as.formula(formula), data = df_filtered_sub, weights = ~nat_weight, vcov = ~G)
#     beta = stats::coef(rw_lm)[["W"]]
#     se = sqrt(diag(stats::vcov(rw_lm)))[["W"]]
#     r2 = fixest::r2(rw_lm)["r2"]
#     
#     mat[v, ] <- c(beta, se, beta/se, if (beta > 0) { sqrt(r2) } else { -sqrt(r2) })
#   }
#   
#   return(mat)
    return mat
# }
end