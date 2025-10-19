This file is dedicated to notes taken during the development of this package.

# About tests

The package should be tested by confronting the output of its functions with the output
of the original R code.
In order to run R code from Julia, we can use the RCall package.

# About files 

The original R files are: 

```
    print.R
    twowayfeweights.R
    twowayfeweights_calculate.R
    twowayfeweights_normalize_var.R
    twowayfeweights_result.R
    utils.R
```

I tried to keep the same logic in the replication package. 