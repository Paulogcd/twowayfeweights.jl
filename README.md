# twowayfeweights.jl

[![Build Status](https://github.com/Paulogcd/twowayfeweights.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Paulogcd/twowayfeweights.jl/actions/workflows/CI.yml?query=branch%3Amain)

This package is the Julia translation of the R twowayfeweights package of the [ERC REALLYCREDIBLE Team](https://credible-answers.github.io), [available here](https://github.com/chaisemartinPackages/twowayfeweights).

It provides a set of functions to compute the two way fixed effects (TWFE) estimate of de Chaisemartin and D'Haultfoeuille (2020), [available here](https://www.aeaweb.org/articles?id=10.1257/aer.20181169).

# Features that are still to implement

- Make stepwise_test_4 pass on GitHub (3 are failing in the "Step5: results" function).
- Harmonize all intermediate tests.
- Harmonize documentation for utils (internal functions).
- Harmonize the display of message in the Julia REPL.
- Harmonize the use of the "weights" argument.
- Remove utils_... at root.

Website-Documentation: 
- Internal process
- Getting Started
- Benchmark
