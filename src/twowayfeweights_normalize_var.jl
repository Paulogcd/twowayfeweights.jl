"""
    twowayfeweights_normalize_var(df, varname)

Internal function to replace a variable by its mean per group and time period.
"""
function twowayfeweights_normalize_var(;df::DataFrames.DataFrame, varname::String)
# twowayfeweights_normalize_var = function(df, varname) {
    # For example: 
    # df = DataFrames.DataFrame(
    #             X = rand(8),
    #             Y = rand(8), 
    #             C = rand(8), 
    #             G = [1,1,1,1,2,2,2,2], 
    #             T = [1,1,2,2,1,1,2,2]
    # )
#   suppressWarnings({ 
#   .data = NULL # This is a "workaround" to avoid no global binding error message. 
    # data = []
#   
#   var = rlang::sym(varname) # Create a symbol out of the string.
    # varname = "C"
    var = Symbol(varname)
#   sdf = df %>%
#     dplyr::group_by(.data$G, .data$T) %>% # This should not work. This works because df has "G" and "T"
    # tmp_df_1 = groupby(df, [:G, :T])
#     dplyr::summarise(tmp_mean_gt = mean(!!var), tmp_sd_gt = stats::sd(!!var))
    # df[:,:G] = [1,1,2,2]
    # df[:,:T] = [1,1,1,1]
    sdf = transform(
        groupby(df, [:G, :T]), 
        var => mean => :tmp_mean_gt, 
        var => std => :tmp_sd_gt
    ); 
    # sdf
    # df
    # Here, we have to choose an approach: 
    # either with transform!, that changes the df directly (and sdf is irrelevant)
    # or create a copy, which can be helpful for clarity.
    # Performance is to be evaluated at the end of the function, for comparison.
    # We have to create a new data frame anyways.
  
#   tmp_sd_gt_sum = sum(sdf$tmp_sd_gt, na.rm=TRUE)
    tmp_sd_gt_sum = sum(sdf.tmp_sd_gt)
    # This condition is essentially if the sum of the temporary standard variation is not null.
    # I don't find strict equivalent of na.rm = TRUE in Julia.
    # This is problematic if I want to handle missing AND NaN.
    # If I want to deal with them separately, it is possible, but not both at the same time.
    # Here are some hints on how I could handle that: 
        # a = [1,2,missing,NaN]
        # sum(skipmissing(a))
        # isnan.(a)
        # map(x -> isnan(x) ? zero(x) : x, a)
        # rr = map(x -> ismissing(x) || isnan(x) ? zero(x) : x, a)
    # missing || true
    # missing || NaN
    # NaN || missing
    # typeof(NaN)
    # isnan(missing) # missing
    # isnan(NaN) # true

#   if (tmp_sd_gt_sum > 0) {
    retcode = (tmp_sd_gt_sum > 0)
    if retcode
        result = sdf
        # innerjoin(df, sdf, on = [:T,:G], makeunique=true)
        # result = leftjoin(df, sdf, on = [:T,:G], makeunique=false)
        # result = leftjoin(df, sdf, on = Pair(:T,:G), makeunique=true) # Useless if I don't create a new dataframe.
        result = transform(result, :tmp_mean_gt => var)
        result = select(result, Not(:tmp_sd_gt, :tmp_mean_gt))
    end
#     df = df %>% 
#       dplyr::left_join(sdf, by=c("T", "G")) %>% # I can just re-use sdf here.
#       dplyr::mutate(!!var := .data$tmp_mean_gt) %>% # I am not sure of what this does: does
#       dplyr::select(-.data$tmp_mean_gt) %>%
#       dplyr::select(-.data$tmp_sd_gt) 
#   } # They take out the tmp columns.
    # I don't understand why they use the retcode condition.
#   })
    # !, !!, !!! and := are rlang functions.

    return (;retocde = retcode, df = result)
end
#   return(list(retcode = (tmp_sd_gt_sum > 0), df = df))
# }
# 

# df = fill(rand(4),5)
# df = DataFrames.DataFrame(df, :auto)
# rename!(df, ["X","Y","G","T","C"])
# df

# For example: 
# df = DataFrames.DataFrame(
#             # X = rand(8),
#             X = [1,2,3,4,5,6,7,8], 
#             # Y = rand(8), 
#             Y = [1,2,3,4,5,6,7,8] * 2,
#             # C = rand(8), 
#             C = [2,3,4,5,6,7,8,9],
#             G = [1,1,1,1,2,2,2,2], 
#             T = [1,1,2,2,1,1,2,2]
# )
# 
# df

# In R: 
# df <- data.frame(X = rnorm(8), 
#                     Y = rnorm(8),
#                     C = rnorm(8),  
#                     G = c(rep(1,4), rep(2,4)),
#                     T = c(1,1,2,2,1,1,2,2))

# rr = twowayfeweights_normalize_var(df = df, varname = "C")

# df.C
# rr.df.C

# rr.df == df

# Not cleaned, but works.

