# About testing

This package takes the stance to test all the results of the functions against the R package, which was intially developed by de Chaisemartin and his team.

To call the R package from julia, we use the package `RCall`.

For example to test the `fn_ctrl_rename()` function, we will call it from the R package with RCall, apply it to an object, and compare this R object with the obtained julia object.


