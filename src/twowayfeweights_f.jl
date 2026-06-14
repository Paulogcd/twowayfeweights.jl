"""
Estimation of the weights attached to the two-way fixed effects regressions.

Estimates the weights and measure of robustness to treatment
  effect heterogeneity attached to two-way fixed effects regressions. 
  
  This function estimates the weights attached to the two-way fixed
  effects regressions studied in de Chaisemartin & D'Haultfoeuille (2020a),
  as well as summary measures of these regressions' robustness to
  heterogeneous treatment effects.

  Returns an object of type "twowayfeweights", which is a wrapper of the
  OrderedCollections.OrderedDict type.
  This wrapper allows for a custom Base.show() method.
  Included among the slots of the returned list object is a data frame
  containing the weights attached to each group*time cell.

  # Arguments
- `data` A data frame or data matrix.

- `Y` Character string. The dependent variable in the regression. Y is the
  level of the outcome if one wants to estimate the weights attached to the
  fixed-effects regression, and Y is the first difference of the outcome if
  one wants to estimate the weights attached to the first-difference
  regression. Required.

- `G` Character string. The variable identifying each group. Required.

- `T` Character string. The variable identifying each period. Required.

- `D` Character string. The treatment variable in the regression. D is the
  level of the treatment if one wants to estimate the weights attached to the
  fixed-effects regression, and D is the first difference of the treatment if
  one wants to estimate the weights attached to the first-difference
  regression. Required.

- `type` Character string. The type of estimation strategy. Can take one
  of four different values, each defining a unique combination of regression
  strategy (either fixed-effects or first-difference) and inference
  assumption (either common trends on its own or common trends plus an
  additional assumption about treatment stability over time).
  * "feTR" (the default): Fixed-effects regression under the common trends assumption.
  * "feS": Fixed-effects regression under common trends and the assumption that groups' treatment effect does not change over time.
  * "fdTR": First-difference regression under the common trends assumption.
  * "fdS": First-difference regression under common trends and the assumption that groups' treatment effect does not change over time.

- `D0` Character string. If `type = "fdTR"` is specified above, then the
  function requires a fifth argument, `D0`. `D0` is the mean of the treatment
  in group g and at period t. It should be non-missing at the first period
  when a group appears in the data (e.g. at t=1 for the groups that are in
  the data from the beginning), and for all observations for which the
  first-difference of the group-level mean outcome and treatment are non
  missing.

- `summary_measures` Logical. Should the complementary results from the
  computation of the weights be displayed? Specifically, the option outputs:
  (i) the point estimate of the coefficient on the D variable from a TWFE
  regression, (ii) the minimum value of the standard deviation of the ATEs
  compatible with the coefficient from the TWFE regression and ATE across all
  treated (g,t) cells being equal to zero, (iii) the minimum value of the
  standard deviation of the ATEs compatible with the coefficient from the
  TWFE regression and ATE across all treated (g,t) cells having different
  signs (this is computed only if the sum of negative weights is different
  from 0). See the FAQ section of the original R package for other details.

- `controls` Character string(s). An optional vector of control variables
  that are included in the regression. Controls should not vary within each
  group*period cell, because the results in in de Chaisemartin &
  D'Haultfoeuille (2020a) apply to two-way fixed effects regressions with
  group×period level controls. If a control does vary within a group×period
  cell, the command will replace it by its average value within each
  group*period cell.

- `other_treatments` Character string(s). An optional vector of other
  treatment variables that are included in the regression. Note that this
  option can only be used when `type = "feTR"` is specified above. While the
  results in de Chaisemartin & D'Haultfoeuille (2020a) do not cover two-way
  fixed effects regressions with several treatments, those in de Chaisemartin
  & D'Haultfoeuille(2020b) do, so the command follows results from that
  second paper when other_treatments is specified. When it is specified, the
  command reports the number and sum of positive and negative weights
  attached to the treatment, but it does not report the summary measures of
  the regression's robustness to heterogeneous treatment effects, as these
  summary measures are no longer applicable when the regression has several
  treatment variables. The command also reports the weights attached to the
  other treatments. The weights reported by the command are those in
  Corollary 1 in de Chaisemartin & D'Haultfoeuille (2020b). See de
  Chaisemartin & D'Haultfoeuille (2020b) for further details.

- `weights` Character string. Specifies a column name in the input data
  that replaces the default weighting scheme. If the regression is weighted,
  the weight variable can be specified in weight. If `type="fdTR"` is
  specified, then the weight variable should be non-missing at the first
  period when a group appears in the data (e.g. at t=1 for the groups that
  are in the data from the beginning), and for all observations for which the
  first-difference of the group-level mean outcome and treatment are non
  missing.

- `test_random_weights` Character string(s). An optional vector that, when
  specified, will cause the function to estimate the correlation between each
  variable in the vector and the weights. Testing if those correlations
  significantly differ from zero is a way to assess whether the weights are
  as good as randomly assigned to groups and time periods.

- `path` File path for saving the results in a valid csv file that
  containing 3 variables (Group, Time, Weight). This option allows the user
  to see the weight attached to each group*time cell. If the other_treatments
  option is specified, the weights attached to the other treatments are also
  saved.

"""
function twowayfeweights(;
    data::DataFrames.DataFrame,
    Y::String,
    G::String,
    T::String,
    D::String,
    type::String = "feTR",
    D0::Union{String, Nothing} = nothing,
    summary_measures::Bool = false,
    controls::Union{String, Nothing} = nothing,
    weights::Union{String, Nothing} = nothing,
    other_treatments::Union{String, Nothing} = nothing,
    test_random_weights::Union{String, Nothing} = nothing,
    path::Union{String, Nothing} = nothing)

    @assert type ∈ ["feTR", "feS", "fdTR", "fdS"] "Argument `type` must be one of `feTR`, `feS`, `fdRTR`, or `fdS`."

    if type == "fdTR" && isnothing(D0)
        @error("The `D0` argument must also be provided if `type = 'fdTR'`.\n")
    end

    if !isnothing(other_treatments) && type != "feTR"
        @error("When the `other_treatments` argument is specified, you need to specify `type = 'feTR'` too.")
    end

    # We rename:
    controls_rename         = get_controls_rename(controls)
    treatments_rename       = get_treatments_rename(other_treatments)
    random_weight_rename    = get_random_weight_rename(test_random_weights)
    
    data_renamed = twowayfeweights_rename_var(
        df = data,
        Y = Y,
        G = G,
        T = T,
        D = D,
        D0 = D0,
        controls = controls,
        treatments = other_treatments,
        random_weights = test_random_weights)
  
    # Transform
    data_transformed = twowayfeweights_transform(
        df          = data_renamed,
        controls    = controls_rename,
        weights     = weights,
        treatments  = test_random_weights)
    
    # Filter
    data_filtered = twowayfeweights_filter(
        df = data_transformed,
        Y = "Y",
        G = "G",
        T = "T",
        D = "D",
        D0 = "D0",
        cmd_type = type,
        controls = controls_rename,
        treatments = treatments_rename)

    # Calculate the weights
    res = twowayfeweights_calculate(
        dat        = data_filtered,
        type       = type,
        controls   = controls_rename,
        treatments = treatments_rename
    )
  
    # Create main return object list
    res = twowayfeweights_result(
        dat            = res[:dat],
        beta           = res[:beta],
        random_weights = random_weight_rename,
        treatments     = treatments_rename
    )

    # Set class and add extra features for post-processing (printing etc.)
    # class(res) = "twowayfeweights"
    
    res[:type]              = type
    res[:params]            = OrderedCollections.OrderedDict(:Y => Y, :G => G, :T => T, :D => D, :D0 => D0)
    res[:summary_measures]  = summary_measures
    res[:other_treatments]  = treatments_rename
    res[:random_weights]    = random_weight_rename

    res = twowayfeweights(res)
  
    if !(isnothing(path))
        # write.csv(res$dat_result, path, row.names = FALSE)
        CSV.write(path, res.dat_result)
    end
  
  return res
  
end