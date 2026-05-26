# twowayfeweights.jl

[![Build Status](https://github.com/Paulo Gugelmo Cavalheiro Dias/twowayfeweights.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Paulo Gugelmo Cavalheiro Dias/twowayfeweights.jl/actions/workflows/CI.yml?query=branch%3Amain)

This package is the Julia translation of the R twowayfeweights package of Clément de ChaiseMartin et al., [available here](https://github.com/chaisemartinPackages/twowayfeweights).

It provides a set of functions to compute the two way fixed effects (TWFE) estimate of de Chaisemartin and D'Haultfoeuille (2020), [available here](https://www.aeaweb.org/articles?id=10.1257/aer.20181169).

# Workflow

1. Once I am done with modifications, I add and commit.
2. I then use Pkg.develop(".") (or "] dev .")
3. Then I include the make.jl file in the docs.

# To do

- twowayfeweights_calculate.R:
    - (to be tested)
    - fix row 287 na.rm

- print.R
- twowayfeweights.R
- twowayfeweights_result.R
- twowayfeweights_transform:
    - Write different methods in case controls, etc.. are vectors{String} or just String.

- Check all documentation of functions.
- Harmonize documentation for utils (internal functions).
- Wherever there are "info" messages, make it prettier using the features of Julia REPL.

# Done
 
- twowayfeweights_normalize_var.R
- utils_1.R
- utils_2.R
- utils_3.R
- utils_4.R
- utils_5.R
- utils_6.R