# Internal package guide

This page is dedicated to the explanation of the internal functioning of the package.
The main function of the package is the twowayfeweights() function, with the appropriated parameters (see the getting started guide for more information).

This function replicates the same behavior as the original R package, such that: 

```mermaid
graph LR
    A[Checks] --> B[Rename functions] --> C[Transform] --> D[Filter] --> E[Calculate] --> F[Result]
```

# 1. Checks

First, the function verifies two conditions: 

If we want to compute the first difference but did not provide the D0 parameter, the function throws an error.
Similarily, one cannot provide other treatments without specifying that the type of wanted computation is feTR, i.e. ...
Finally, the code assert that the relevant columns contain numerical values.

```julia
if type == "fdTR" && isnothing(D0)
    @error("The `D0` argument must also be provided if `type = 'fdTR'`.\n")
end

if isnothing(other_treatments) && type != "feTR"
    @error("When the `other_treatments` argument is specified, you need to specify `type = 'feTR'` too.")
end

columns_to_check = ifelse(D0 in names(data), [Y, G, T, D, D0], [Y, G, T, D])
for v in columns_to_check
    if !(data[:, v] isa Vector{<:Number})
        data[:, v] = parse.(Float64, data[:, v])
    end
end
```

If the type is "fdTR", i.e. we want to compute the first difference under the common trend assumption, we need the D0 parameter.
D0 is the mean of the treatment in group g at period t

If we include other treatments, we need to specify that the type is "feTR", i.e. we want to compute the fixed effect difference under the common trend assumption,

# 2. Renaming

# 3. Transform

# 4. Filter

# 5. Calculate

# 6. Result



