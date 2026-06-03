# Package guide

The TwoWayFEWeights.jl package computes the weights associated with TWFE regression and the robust estimator proposed by Dechaisemartin 2020.


# Main function

## Type of computation: 

|  | Common Trend Assumption | Group treatment does not change over time |
|----|----|----|
| Fixed-Effects Regression  | feTR  | feS  |
| First Difference Regression  | fdTR  | fdS  |