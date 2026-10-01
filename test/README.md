# About testing

This package takes the stance to test all the results of the functions against the R package, which was intially developed by de Chaisemartin and his team.

To call the R package from julia, we use the package `RCall`.

For example to test the `fn_ctrl_rename()` function, we will call it from the R package with RCall, apply it to an object, and compare this R object with the obtained julia object.


# Updates about testing 

Since late September 2026, several new features were added to the testing section of the package.

A step-by-step testing process is now prioritized: 

- test_step_1_renaming
- test_step_2_transform
- test_step_3_filter
- test_step_4_calculate
- test_step_5_result

Moreover, for each new step computed, the julia and R data is saved in /test/data/output in the following way: 

```
function save_test_data(data_R, data_julia)
    RCall.@rput data_R
    RCall.rcopy(R"
        base::saveRDS(
            object = data_R,
            file = file.path(getwd(), \"test\", \"data\", \"output\", \"data_R.rds\")
        )")
    JLD2.@save joinpath(@__DIR__, "data", "output", "data_julia.jld2") data_julia;
end
```


This allows an easier testing process from an external R environment.
In R, we can indeed load the data as: 

```
    # Load the whole list:
    data_R <- base::readRDS(
        file = file.path("/", "Users", "paulogcd", "twowayfeweights.jl", "test", "data", "output", "data_R_3.rds"))
    
    # And then each item of data_R:
    dt <- data_R$data_filtered
    type <- data_R$type
    controls <- data_R$controls_rename
    treatments <- data_R$treatments_rename
```

# Result of step 2

## Julia:
data_julia = JLD2.load(joinpath("/Users", "paulogcd", "twowayfeweights.jl", "test", "data", "output", string("data_julia_", 2, ".jld2")))["data_julia"]

## R:

data_R <- base::readRDS(
        file = file.path('/', 'Users', 'paulogcd', 'twowayfeweights.jl', 'test', 'data', 'output', 'data_R_2.rds'))
data_R$data_filtered = TwoWayFEWeights:::twowayfeweights_filter(
    data_R$data_transformed,
    data_R$Y,
    data_R$G,
    data_R$T,
    data_R$D,
    data_R$D0,
    data_R$type,
    data_R$controls_rename,
    data_R$treatments_rename
)

# Result of the step 3

data_julia = JLD2.load(joinpath("/Users", "paulogcd", "twowayfeweights.jl", "test", "data", "output", string("data_julia_", 3, ".jld2")))["data_julia"]

dat        = data_julia[:data_filtered]
type       = data_julia[:type]
controls   = data_julia[:controls_rename]
treatments = data_julia[:treatments_rename]



