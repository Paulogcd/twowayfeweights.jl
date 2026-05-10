"""
    fn_ctrl_rename(x)

Rename variables by writing "ctrl_" at their beginning.
The `fn_ctrl_rename` function is the equivalent of the original `fn_ctrl_rename` function, defined in the original R code such as: 
    fn_ctrl_rename <- function(x) paste("ctrl", x, sep="_")

# Examples
```jldoctest
julia> twowayfeweights.x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4

julia> twowayfeweights.fn_ctrl_rename(x)
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
julia> twowayfeweights.x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4

julia> twowayfeweights.fn_ctrl_rename(x)
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
    fn_treatment_rename(treatments)

    Rename a vector of variable names by placing "OT" in front of it.
"""
function fn_treatment_rename(treatments)
    string.("OT_", treatments)
end

"""
    get_treatments_rename(treatments)

Rename a vector of variables by putting "OT_" in front of them.
The `get_treatments_rename` function is the equivalent of the original `get_treatments_rename` function, defined in the original R code such as: 
    get_treatments_rename <- function(treatments) {unlist(lapply(treatments, fn_treatment_rename))}

```jldoctest
julia> twowayfeweights.x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4

julia> twowayfeweights.get_treatments_rename(x)
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
julia> twowayfeweights.x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4
julia> twowayfeweights.fn_treatment_weight_rename(x)
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
    return result
end


"""
    fn_random_weight_rename(x)

Rename a vector of variables by putting "RW_" in front of them.
The `fn_random_weight_rename` function is the equivalent of the original `fn_random_weight_rename` function, defined in the original R code such as: 
    fn_random_weight_rename <- function(x) paste("RW", x, sep="_")

```jldoctest
julia> twowayfeweights.x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4
julia> twowayfeweights.fn_random_weight_rename(x)
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
julia> twowayfeweights.x = [1,2,3,4]
4-element Vector{Int64}:
 1
 2
 3
 4
julia> twowayfeweights.get_random_weight_rename(x)
4-element Vector{String}:
 "RW_1"
 "RW_2"
 "RW_3"
 "RW_4"
```
"""
function get_random_weight_rename(ws)
    ws = string.(ws)
    result = twowayfeweights.fn_random_weight_rename(ws)
    return result
end
