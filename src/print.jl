# Written, but not tested.

"""
A print method for twowayfeweights objects.
Printed display of twowayfeweights objects.

"""
function print_twowayfeweights(x)
    # https://docs.julialang.org/en/v1/manual/types/#man-custom-pretty-printing
    # Check this link for custom printing function.
# function print(x::twowayfeweights) # Maybe like that?

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
            string("the TWFE coefficient beta, equal to", x[:beta], "estimates the sum of several terms.\n\n") * 
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

    @info(string("\n", assumption_string, "\n", weight_string, "\n, \n"))

    tmat = [
        [x[:nr_plus], x[:nr_minus], tot_weights],
        [round(x[:sum_plus], digits = 4), round(x[:sum_minus], digits = 4), tot_sums]
    ]

    ## Rather use custom print method defined below
    # print_treat_matrix(tmat = tmat, tvar = x[:params][:D], ttype = treat) # Later defined.

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

            @info(
                string(
                    "\n\n", 
                    oassumption_string, 
                    "\n", 
                    oweight_string, 
                    "\n\n", 
                    print_treat_matrix(tmat = otmat, tvar = otvar, ttype = treat, otreat = TRUE)
                )
            )
        end
    end

    if x[:summary_measures]
        
        subscr = x[:type][1:2]
        @info("Summary Measures:")
        @info(string(" TWFE Coefficient β_fe: ", x[:beta]))
        
        if !isnothing(x[:sensibility])
        
            @info(string("\n"," min \U03C3(\U0394) compatible with \U03B2_", subscr, " and \U0394_TR = 0: ", x[:sensibility]))
        
            if x[:sensibility2] > 0 && x[:sum_minus] < 0
                @info(string("\n   min \U03C3(\U0394) compatible with treatment effect of opposite sign than \U03B2_", 
                subscr,
                " in all (g,t) cells: ", 
                x[:sensibility2]
                ))
            end
            @info(string("\n Reference: Corollary 1, de Chaisemartin, C, and D'Haultfoeille, X (2020a)"))
        end
    end

    if !isnothing(x[:random_weights])
        @info(string("Regression of variables possibly correlated with the treatment effect on the weights:",  x[:mat]))
    end

    @info(
        "The development of the original package (R and Stata) was funded by the European Union (ERC, REALLYCREDIBLE,GA N. 101043899).
        The first version of this Julia package was written by Paulo Gugelmo Cavalheiro Dias.\n\n")

  return x; # 'invisible' does not exist in Julia.
end


## Custom print print method for treatment matrix
# print_treat_matrix = function(tmat, tvar, ttype, otreat = FALSE) {
function print_treat_matrix(tmat, tvar, ttype, otreat = false)

    tmat = [
        ["Positive weights", "Negative weights", "Total"]
        tmat
    ]

  # if (otreat) {
  #   tstring = paste0("Other treat.: ", gsub("^OT_", "", tvar))
  # } else {
  #   tstring = paste0("Treat. var: ", tvar)
  # }
    if otreat 
        tstring = string("Other treat.: ", replace(tvar, "^OT" => ""))
    else
        tstring = "Treat. var:" .* tvar
    end

    tmat = [tstring, string(ttype, "s"), string("\U03A3", " weights")]

    # Calculate the width for each column
    # col_widths = apply(tmat, 2, function(x) max(nchar(x)))
    col_widts = max(length(tmat)) # ? 


  # Function to format a single row based on column widths
  # format_row = function(row) {
  #  formatted_elements = mapply(function(x, width, idx) {
  #    if (idx == 1) {
  #      sprintf("%-*s", width, x)  # Left-align the first column
  #    } else {
  #      sprintf("%*s", width, x)   # Right-align all other columns
  #    }
  #  }, row, col_widths, seq_along(row))
  #  paste(formatted_elements, collapse = "    ")
  # }
  # function format_row(row) 
  #  formatted_elements = ...
  # end

  # Create the header and separator line
  # header = format_row(tmat[1, ])
  header = tmat[1, ]
  # bold_header = cli::style_bold(header)
  # Calculate the separator line width
  # separator_line_width = nchar(header)

  # Print separator line before header
  # cat(cli::rule(width = separator_line_width), "\n")
  # Print the bold header
  # cat(bold_header, "\n")
  @info(header, "\n")
  # Print separator line after header
  # cat(cli::rule(width = separator_line_width), "\n")

  # Print the body of the matrix except the last row
  # for (i in 2:(nrow(tmat) - 1)) {
  #   cat(format_row(tmat[i, ]), "\n")
  # }
  for i in 2:(nrow(tmat) - 1)
    print(tmat[i,:]), "\n" # See if it really is readable.
  end

  # Print separator line before last row
  # cat(cli::rule(width = separator_line_width), "\n")
  # Print the last row
  # cat(format_row(tmat[nrow(tmat), ]), "\n")
  @info(tmat[end,:], "\n")
  # Print separator line after last row
  # cat(cli::rule(width = separator_line_width))

end


# Function to format a single row based on column widths
function format_row(row)

    formatted_elements = mapply(function(x, width, idx) {
    if idx == 1
        string(width, x)
    else
    

    end
    if (idx == 1) {
        sprintf("%-*s", width, x)  # Left-align the first column
    } else {
        sprintf("%*s", width, x)   # Right-align all other columns
    }
    }, row, col_widths, seq_along(row))
    paste(formatted_elements, collapse = "    ")
    }


end