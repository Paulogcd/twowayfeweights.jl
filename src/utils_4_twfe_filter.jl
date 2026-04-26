"""
    twowayfeweights_filter(df, Y, G, T, D, D0, cmd_type, controls, treatments)

Description.
"""
function twowayfeweights_filter(df, Y, G, T, D, D0, cmd_type, controls, treatments)
#   .data = NULL
    data = []
#   # Remove rows with NA values
#   if (cmd_type != "fdTR") { 
    if(cmd_type != "fdTR") #? What is this class?
#     df <- df %>%
#       dplyr::mutate(tag = rowSums(dplyr::across(.cols = c(Y, G, T, D, controls, treatments), .fns = is.na))) %>%
#       dplyr::filter(.data$tag == 0) %>%
#       dplyr::select(-.data$tag)
        gdf = DataFrames.transform(
            DataFrames.groupby(df,
                [:Y,:G,:T,:D,:controls,:treatments]), 
            
        )
#   } else {
    else
#     df <- df %>%
#       dplyr::mutate(tag1 = rowSums(dplyr::across(.cols = c(D, T, Y), .fns = is.na))) %>%
#       dplyr::mutate(tag2 = rowSums(dplyr::across(.cols = c(D0), .fns = is.na))) %>%
#       dplyr::filter(.data$tag1 == 0 | .data$tag2 == 0)
#     
#     if (length(controls) > 0) {
#       df <- df %>%
#         dplyr::mutate(tag3 = rowSums(dplyr::across(.cols = controls, .fns = is.na))) %>%
#         dplyr::filter(.data$tag1 == 1 | .data$tag3 == 0) %>%
#         dplyr::select(-.data$tag3)
#     }
#     df <- df %>% dplyr::select(-.data$tag1, -.data$tag2)
    end
        df = df[:,Not(data.tag1, data.tag2)]
#   }
#   return(df)
    return df
# }
end