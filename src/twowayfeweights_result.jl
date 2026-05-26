"""
Internal workhorse function for creating the return object of a
`twowayfeweights()` call.

@param dat A data frame, as per the return object from
  `twowayfeweights_calculate()`.
@param beta Coefficient value of the treatment variable ("D"), again as per
  the return object of `twowayfeweights_calculate()`.
@param controls A vector indicating the column names of random weights.
@param treatments A vector indicating the column names of other treatments.
@returns A list.
@details This function is normally run directly after
  `twowayfeweights_calculate()`.
@importFrom magrittr %>%
@noRd
"""
function twowayfeweights_result(;
    dat,
    beta,
    random_weights,
    treatments = NULL)

    # Original comment:
    # Two distinct cases/workflows:
    #  1) No other treatments,
    #  2) With other treatments
  
    if isnothing(treatments)
    
        # Avoid overcounting of positive and negative weights close to 0
        limit_sensitivity = 10^(-10)
        dat.weight_result = ifelse.(dat.weight_result .< limit_sensitivity .&& dat.weight_result .> -limit_sensitivity, 0, dat.weight_result)
        ret = twowayfeweights_summarize_weights(df = dat, var_weight = "weight_result")
        
        W_mean = weighted_mean(x = dat.W, w = dat.nat_weight) # Check: is this the one I use, or not?
        # Original comment: 
        # Modif. Diego: DoF adjustment to the sd of w_gt
        M       = sum((dat.nat_weight .!= 0)) # Number of non null values.
        W_sd    = sqrt(sum(skipmissing(dat.nat_weight .* (dat.W .- W_mean).^2))) * sqrt(M/(M - 1)) # na.rm here
        sensibility = abs.(beta) ./ W_sd
        
        dat_result = dat[:, [:T, :G, :weight_result]]
        rename!(dat_result, :weight_result => :weight) 
        
        ret[:dat_result] = dat_result
        ret[:beta] = beta
        ret[:sensibility] = sensibility

        if !isnothing(random_weights)
        
            ret[:mat] = twowayfeweights_test_random_weights(df = dat, random_weights = random_weights)
        
        end
        
        if ret[:sum_minus] < 0
            
            dat_sens = dat[dat[: , :weight_result] .!= 0, :]
            dat_sens = DataFrames.sort(dat_sens, [order(:W, rev = true)])
            dat_sens.P_k .= 0
            dat_sens.S_k .= 0
            dat_sens.T_k .= 0

            # To do:
            # # Modif. Diego: Replaced the previous two loops with build-in routines
            N = nrow(dat_sens)
            dat_sens = DataFrames.sort(dat_sens, [order(:W), order(:G, rev = true), order(:T, rev = true)])
            dat_sens.Wsq = dat_sens.nat_weight .* (dat_sens.W .^ 2)
            dat_sens.P_k = cumsum(dat_sens.nat_weight)
            dat_sens.S_k = cumsum(dat_sens.weight_result)
            dat_sens.T_k = cumsum(dat_sens.Wsq)
            
            # dat_sens = dat_sens[order(-dat_sens$W, dat_sens$G, dat_sens$T),]
            dat_sens = DataFrames.sort(dat_sens, [order(:W, rev = true), order(:G), order(:T)])
            dat_sens.sens_measure2 = (abs.(beta) ./ sqrt.(dat_sens.T_k + ((dat_sens.S_k.^2) ./ (1 .- dat_sens.P_k))))

            #     dplyr::mutate(sens_measure2 = abs(beta) / sqrt(.data$T_k + .data$S_k^2 / (1 - .data$P_k))) %>%
            dat_sens.indicator .= dat_sens.W .<  (.-(dat_sens.S_k)) ./ (1 .- dat_sens.P_k)
            #     dplyr::mutate(indicator = as.numeric(.data$W < - .data$S_k / (1 - .data$P_k)))
            # dat_sens$indicator[1] = 0
            dat_sens.indicator[1] = 0
            dat_sens.indicator_l = lag(dat_sens.indicator, default = -1)
            # dat_sens = dat_sens %>%
            #     dplyr::mutate(indicator_l = dplyr::lag(.data$indicator, default = -1))
            dat_sens.indicator .= max.(dat_sens.indicator, dat_sens.indicator_l)
            # dat_sens = dat_sens %>%
            #     dplyr::rowwise() %>%
            #     dplyr::mutate(indicator=max(.data$indicator, .data$indicator_l))
            # total_indicator = sum(dat_sens$indicator)
            total_indicator = sum(dat_sens.indicator)
            sensibility2 = dat_sens.sens_measure2[N - total_indicator + 1]
            ret[:sensibility2] = sensibility2
        end

        # Since, with one treatment, we could have either D or D0 as the main treatment, 
        # the row below computes the number of cells such that their treatment is different than 0
        ret[:tot_cells] = sum(skipmissing(dat.nat_weight) .!= 0) # na.rm here
    
    else
        limit_sensitivity = 10^(-10)
        
        for v in ["result", treatments]
            if !isnothing(v)
                dat[:, Symbol("weight_", v)] = ifelse.(dat[:, Symbol("weight_", v)] .< limit_sensitivity .&& dat[:, Symbol("weight_", v)] .> -limit_sensitivity, 0, dat[:, Symbol("weight_", v)])
            end
        end
        
        columns = ["T", "G", "weight_result"]
        ret = twowayfeweights_summarize_weights(df = dat, var_weight = "weight_result") # Error here, not all fields are included.
        ret[:tot_cells] = sum((skipmissing(dat.nat_weight) .!= 0)) # na.rm here
        
        if !isnothing(random_weights)
            ret[:mat] = twowayfeweights_test_random_weights(df = dat, random_weights = random_weights)
        end
        
        if !isnothing(treatments)
            for treatment in treatments
                varname = fn_treatment_weight_rename(treatment)
                columns = [columns, varname]
                ret2 = twowayfeweights_summarize_weights(df = dat, var_weights = varname)
                ret[:treatment] = ret2
                ret[:treatment][:tot_cells] = sum(skipmissing(dat.treatment != 0)) # na.rm here
            end
        end
        
        # dat_result = dat %>%
        #     dplyr::select_at(dplyr::vars(columns)) %>% 
        #     dplyr::rename(weight = .data$weight_result)

        dat_result = dat[:, columns]
        dat_result = DataFrames.rename(dat_result, :weight_result => :weight)

        
        ret[:beta] = beta
        ret[:dat_result] = dat_result
        
    end

    return(ret)

end