RCall.rcopy(R"
    packages <- c('haven', 'dplyr', 'TwoWayFEWeights')

    for (pkg in packages){
        test_result <- requireNamespace(pkg)
        if(test_result == FALSE){
            install.packages(pkg, repos = 'https://cloud.r-project.org')
        }
    }
")