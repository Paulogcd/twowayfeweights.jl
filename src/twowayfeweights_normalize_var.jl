"""
    twowayfeweights_normalize_var(df, varname)

Internal function to replace a variable by its mean per group and time period.
"""
function twowayfeweights_normalize_var(;
    df::DataFrames.DataFrame,
    varname::String)

    var = Symbol(varname)
    sdf = DataFrames.transform(
        DataFrames.groupby(df, [:G, :T]),
        var => Statistics.mean => :tmp_mean_gt, 
        var => Statistics.std => :tmp_sd_gt
    )

    # The R package uses sum(, na.rm - TRUE).
    # This condition is essential if the sum of the temporary standard variation is not null.
    # I don't find strict equivalent of na.rm = TRUE in Julia.
    # This is problematic if I want to handle missing AND NaN.
    # If I want to deal with them separately, it is possible, but not both at the same time.
    # To respect the spirit of the original package, we choose to remove both missings and NaNs from the vector.
    sdf.tmp_sd_gt = DataFrames.coalesce.(sdf.tmp_sd_gt, 0) # for missing values
    sdf.tmp_sd_gt = ifelse.(isnan.(sdf.tmp_sd_gt), 0, sdf.tmp_sd_gt) # for nan values
    
    tmp_sd_gt_sum = sum(sdf[!,:tmp_sd_gt])

    retcode     = (tmp_sd_gt_sum > 0)
    result      = []
    if retocde
        result = leftjoin(df, sdf, on = [:T, :G], makeunique = true)
        result = transform(result, :tmp_mean_gt => var)
        result = select(result, Not(:tmp_sd_gt, :tmp_mean_gt))
    end

    return OrderedCollections.OrderedDict(:retcode => retcode, :df => result)

end
# Does not work.
# Seems to produce more rows than expected, with the leftjoin not working.