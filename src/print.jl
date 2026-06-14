# Written, but not tested.

"""
A print method for twowayfeweights objects.
Printed display of twowayfeweights objects.

    For the definition of the twowayfeweights struct, go see "twowayfeweights_struct".

"""
function Base.show(io::IO, x::twowayfeweights)
    # https://docs.julialang.org/en/v1/manual/types/#man-custom-pretty-printing
    # Check this link for custom printing function.
    # Base.show(x::twowayfeweights)

    full_assumption_message     = ""
    assumption_string_tmat      = ""
    summary_measures_string     = ""
    random_weight_message       = ""
    message_ERC                 = ""

    other_treats = !isnothing(x[:other_treatments])

    treat = "ATT"

    assumption = if x[:type] ∈ ["feTR", "fdTR"]
            "Under the common trends assumption,\n"
        elseif x[:type] ∈ ["feS", "fdS"]
            "Under the common trends, treatment monotonicity, and if groups' treatment effect does not change over time,\n"
        else 
            "BLANK"
        end

    if other_treats
        assumption_string = string(assumption * 
            string("the TWFE coefficient beta, equal to", x[:beta], "estimates the sum of several terms.") * 
            string("The first term is a weighted sum of ", x[:nr_plus] + x[:nr_minus], " ", treat, ".")
        )
    else 
        assumption_string = string(assumption *
            string("the TWFE coefficient beta, equal to ", x[:beta], ", estimates a weighted sum of ", x[:nr_plus] + x[:nr_minus], " ", treat)
        )
    end

    weight_string = string(
        x[:nr_plus],
        " ",
        treat, 
        "receive a positive weight, and ", 
        x[:nr_minus],
        " receive a negative weight."
    )

    if x[:tot_cells] > x[:nr_plus] + x[:nr_minus]
        weight_string = string(
            weight_string, # 1
            "\n", 
            x[:tot_cells], # 2
            " (g,t) cells receive the treatment, but the ",
            treat, # 3
            " of ",
            x[:tot_cells] - (x[:nr_plus] + x[:nr_minus]), # 4
            " cells receive a weight equal to zero.")
    end

    tot_weights = x[:nr_plus] + x[:nr_minus]
    tot_sums = round(x[:sum_plus] + x[:sum_minus], digits = 4)

    full_assumption_message = string("\n", assumption_string, "\n", weight_string)

    tmat = Matrix{Float64}(undef, 2, 3)
    tmat[1, :] = [x[:nr_plus], x[:nr_minus], tot_weights]
    tmat[2, :] = [round(x[:sum_plus], digits = 4), round(x[:sum_minus], digits = 4), tot_sums]
    tmat = permutedims(tmat)

    treat_matrix_string = print_treat_matrix(tmat = tmat, tvar = x[:params][:D], ttype = treat)

    # print other treatments
    if other_treats # OTHER_TREATS BLOCK
        for otvar in x[:other_treatments]

            ox = x[:otvar]
            otot_weights = ox[:nr_plus] + ox[:nr_minus]
            otot_sums = round(ox[:sum_plus] + ox[:sum_minus], 4)

            otmat = [
                [ox[:nr_plus], ox[:nr_minus], otot_weights], 
                [round(ox[:sum_plus], 4), round(ox[:sum_minus], 4), otot_sums]
            ]

            oassumption_string = string("The next term is a weighted sum of ", ox[:nr_plus] + ox[:nr_minus], " ", treat)
            
            oweight_string = string(
                ox[:r_plus] * treat * " receive a positive weight, and and " * ox[:nr_minus] * " reveive a negative weight."
            )

            if ox[:tot_cells] > ox[:nr_plus] + ox[:nr_minus]
                oweight_string = string(oweight_string,
                    ox[:tot_cells],
                    "(g,t) cells receive the treatment, but the ",
                    treat,
                    "of",
                    ox[:tot_cells] - (ox[:nr_plus] + ox[:nr_minus]),
                    "cells receive a weight equal to zero.")
            end
            
            # Je sens que cette ligne va poser problème.
            assumption_string_tmat = string(oassumption_string, "\n", oweight_string, print_treat_matrix(tmat = otmat, tvar = otvar, ttype = treat, otreat = TRUE))

        end
    end

    if x[:summary_measures]
        
        subscr = x[:type][1:2]
        summary_measures_string = "Summary Measures:\n TWFE Coefficient β_fe: " * string(x[:beta][1])
        
        if !isnothing(x[:sensibility])
        
            summary_measures_string = summary_measures_string * "\n" * "   min \U03C3(\U0394) compatible with \U03B2_" * subscr * " and \U0394_TR = 0: " * string(x[:sensibility])
        
            if (:sensibility2 in keys(x)) && x[:sensibility2] > 0 && x[:sum_minus] < 0
                summary_measures_string = summary_measures_string * "\n" * "   min \U03C3(\U0394) compatible with treatment effect of opposite sign than \U03B2_" * subscr * " in all (g,t) cells: " * string(x[:sensibility2])
            end
            summary_measures_string = summary_measures_string * "\n Reference: Corollary 1, de Chaisemartin, C, and D'Haultfoeille, X (2020a)"
        end
    end

    if !isnothing(x[:random_weights])
        random_weight_message = string("Regression of variables possibly correlated with the treatment effect on the weights:\n",  sprint(io -> PrettyTables.pretty_table(io, x[:mat])))
    end

    message_ERC = string(
        "\nThe development of the original packages (R and Stata) was funded by the European Union (ERC, REALLYCREDIBLE,GA N. 101043899).")

    message = """
    $full_assumption_message
    $assumption_string_tmat
    $treat_matrix_string
    $summary_measures_string
    
    $random_weight_message
    $message_ERC
    """

    @info(message)
end
