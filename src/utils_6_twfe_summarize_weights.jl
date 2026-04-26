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