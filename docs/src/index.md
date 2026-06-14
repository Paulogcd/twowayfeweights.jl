# TwoWayFEWeights.jl

Welcome to the website of the `TwoWayFEWeights.jl` package.

The TwoWayFEWeights.jl package computes the weights associated with TWFE regression and the robust estimator proposed by [de Chaisemartin & D'Haultfœuille 2020](https://www.aeaweb.org/articles?id=10.1257/aer.20181169). It is the replication of an original R package ([available here](https://github.com/Credible-Answers/twowayfeweights)), developed by the [ERC REALLYCREDIBLE Team](https://credible-answers.github.io).

# Main function

## Type of computation

|  | Common Trend Assumption | Group treatment does not change over time |
|----|----|----|
| Fixed-Effects Regression  | feTR  | feS  |
| First Difference Regression  | fdTR  | fdS  |

## Examples

In order to run the examples, we are going to load the example dataset of the original package:
```julia
url = "https://raw.githubusercontent.com/chaisemartinPackages/twowayfeweights/main/wagepan_twfeweights.dta"
path = Downloads.download(url)
wagepan = ReadStatTables.readstat(path)
wagepan = DataFrames.DataFrame(wagepan)
```

```julia
julia_resultat = twowayfeweights(
    data                = wagepan,
    Y                   = "lwage",
    G                   = "nr",
    T                   = "year",
    D                   = "union",
    type                = "feTR",
    summary_measures    = true,
    test_random_weights = "educ")
```

```julia
julia_resultat = twowayfeweights(
    data = wagepan,
    Y = "lwage",
    G = "nr",
    T = "year",
    D = "union",
    type = "feS",
    summary_measures = true,
    test_random_weights = "educ")
```     
        
```julia
julia_resultat = twowayfeweights(
        data = wagepan,
        Y = "diff_lwage",
        G = "nr",
        T = "year",
        D = "diff_union", # use differenced versions of Y and D
        type                = "fdTR",             # changed
        D0                  = "union",            # added (req'd arg for fdTR type)
        summary_measures    = true,
        test_random_weights = "educ")
```

```julia
julia_resultat = twowayfeweights(
    data                = wagepan,
    Y                   = "diff_lwage",
    G                   = "nr",
    T                   = "year",
    D                   = "diff_union",
    type                = "fdS",
    D0                  = "union",
    summary_measures    = true,
    test_random_weights = "educ")
```