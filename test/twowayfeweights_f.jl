@testset twowayfeweights begin

    using ReadStatTables

    # For this test, we are going to use the official / original 
    # code snipped used in the original package.
    repo = "chaisemartinPackages/twowayfeweights/main"
    file = "wagepan_twfeweights.dta"
    url = "https://raw.githubusercontent.com" * "/" * repo * "/" * file
    path = download(url)
    wagepan = ReadStatTables.readstat(path)
    wagepan = DataFrames.DataFrame(wagepan)

    twowayfeweights(
        data = wagepan,
        Y = "lwage",
        G = "nr",
        T = "year",
        D = "union",
        type = "feTR",
        summary_measures = true,
        test_random_weights = "educ")

data = wagepan
Y = "lwage"
G = "nr"
T = "year"
D = "union"
type = "feTR"
summary_measures = true
test_random_weights = "educ"

    #' twowayfeweights(
#'   wagepan,                        # input data
#'   "lwage", "nr", "year", "union", # Y, G, T, & D
#'   type                = "feTR",   # estimation type ("feTR" is the default)
#'   summary_measures    = TRUE,     # show summary measures (optional)
#'   test_random_weights = "educ"    # check randonmess of weights (optional)
#' )



end