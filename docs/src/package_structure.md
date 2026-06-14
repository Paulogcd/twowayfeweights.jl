# Internal package guide

This page is dedicated to the explanation of the internal functioning of the package.
The main function of the package is the twowayfeweights() function, with the appropriated parameters (see the getting started guide for more information).

This function replicates the same behavior as the original R package, such that: 

```mermaid
graph LR
    A[Checks] --> B[Rename functions] --> C[Transform] --> D[Filter] --> E[Calculate] --> F[Result]
```
