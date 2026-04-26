
# twowayfeweights_transform <- function(df, controls, weights, treatments) {
function twowayfeweights_transform(;
    df::DataFrames.DataFrame,
    controls,
    weights,
    treatments)

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
