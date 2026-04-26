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