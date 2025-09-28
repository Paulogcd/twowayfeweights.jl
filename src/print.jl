#' @title A print method for twowayfeweights objects
#' @name print.twowayfeweights
#' @description Printed display of twowayfeweights objects.
#' @param x A twowayfeweights object.
#' @param ... Currently ignored.
#' @inherit twowayfeweights examples
#' @export
# function print_twowayfeweights(x, ...) # print.twowayfeweights is not accepted.
# print.twowayfeweights = function(x, ...) {

  # other_treats = !is.null(x$other_treatments)
    other_treats = length(x$other_treatments)

  # treat = "ATT"
    treat = "ATT"

  # assumption = if (x$type %in% c("feTR", "fdTR")) {
    assumption = if typeof(x) ∈ ["feTR", "fdTR"]
            "Under the common trends assumption,\n"
    # } else if (x$type %in% c("feS", "fdS")) {
        elseif typeof(x) ∈ ["feS", "fdS"]
            "Under the common trends, treatment monotonicity, and if groups' treatment effect does not change over time,\n"
    # } else "BLANK"
        else 
            "BLANK"
        end

  # if (other_treats) {
    if other_treats
    # assumption_string = paste(
    #   assumption,
    #   sprintf("the TWFE coefficient beta, equal to %.4f, estimates the sum of several terms.\n\n", x$beta),
    #   sprintf("The first term is a weighted sum of %d %ss.", x$nr_plus + x$nr_minus, treat), 
    #   sep = ""
    # )
        assumption_string = string(assumption, 
            print("the TWFE coefficient beta, equal to %.4f, estimates the sum of several terms.\n\n", x.beta),
            print("The first term is a weighted sum of %d %ss.", x.nr_plus + x.nr_minus, treat), 
        )
  # } else {
    else 
    # assumption_string = paste(
    #   assumption,
    #   sprintf("the TWFE coefficient beta, equal to %.4f, estimates a weighted sum of %d %ss.", x$beta, x$nr_plus + x$nr_minus, treat), 
    #   sep = ""
    # )
        assumption_string = string(assumption, 
            print("the TWFE coefficient beta, equal to %.4f, estimates a weighted sum of %d %ss.", x$beta, x$nr_plus + x$nr_minus, treat), 
        )
  # } 

  # weight_string = sprintf(
    weight_string = print(
        x.nr_plus, 
        treat, 
        "receive a positive weight, and", 
        x.nr_minus, 
        "receive a negative weight."
    )
    # "%d %ss receive a positive weight, and %d receive a negative weight.",
    # x$nr_plus,
    # treat,
    # x$nr_minus
    # )
  # if (x$tot_cells > x$nr_plus + x$nr_minus) {
    if x.tot_cells > x.nr_plus + x.nr_minus
        weight_string = print(
            weight_string, # 1
            "\n", 
            x.tot_cells, # 2
            " (g,t) cells receive the treatment, but the ",
            treat,
            " of ",
            x.tot_cells - (x.nr_plus + x.nr_minus),
            " cells receive a weight equal to zero. ")
        # weight_string = sprintf("%s\n%d (g,t) cells receive the treatment, 
        # but the %ss of %d cells receive a weight equal to zero.", 
        # weight_string, x$tot_cells, treat, x$tot_cells - (x$nr_plus + x$nr_minus))
    # }

    # tot_weights = x$nr_plus + x$nr_minus
        tot_weights = x.nr_plus + x.nr_minus
    # tot_sums = round(x$sum_plus + x$sum_minus, 4)
        tot_sums = round(x.sum_plus + x.sum_minus, 4)

    # # cat("\n")
    # # cat(cli::rule())
    # cat("\n")
    # cat(assumption_string)
    @info("\n", assumption, "\n", weight_string, "\n, \n")
    # cat("\n")
    # cat(weight_string)
    # cat("\n")
    # cat("\n")

  # tmat = cbind(
    tmat = append(
        [x$nr_plus, x$nr_minus, tot_weights],
        [round(x.sum_plus, digits = 4), round(x.sum_minus, digits = 4), tot_sums]
    )
  #   c(x$nr_plus, x$nr_minus, tot_weights),
  #   c(round(x$sum_plus, 4), round(x$sum_minus, 4), tot_sums)
  # )

  ## Rather use custom print method defined below
  # colnames(tmat) = c(paste0(treat, "s"), paste0("\U03A3", " weights"))
    rename(tmat) = [string(treat, "s"), string("\U03A3", " weights")]
  # rownames(tmat) = c("Positive weights", "Negative weights", "Total")
        # There is no row names in DataFrames.jl
    tmat[:name] = ["Positive weights", "Negative weights", "Total"]
  # cat(paste0("Treat. var: ", x$params$D), "\n")
    @info(string("Treat. var: ", x.params.D, "\n"))
  # # print(tmat, quote = FALSE, print.gap = 2L, right = TRUE)
  # print_treat_matrix(tmat = tmat, tvar = x$params$D, ttype = treat)
  print_treat_matrix(tmat = tmat, tvar = x$params$D, ttype = treat) # This is a function later defined.



  # print other treatments
  if (other_treats) {
    for (otvar in x$other_treatments) {

      ox = x[[otvar]]

      otot_weights = ox$nr_plus + ox$nr_minus
      otot_sums = round(ox$sum_plus + ox$sum_minus, 4)

      otmat = cbind(
        c(ox$nr_plus, ox$nr_minus, otot_weights),
        c(round(ox$sum_plus, 4), round(ox$sum_minus, 4), otot_sums)
      )

      oassumption_string = sprintf("The next term is a weighted sum of %d %ss.", ox$nr_plus + ox$nr_minus, treat)
      oweight_string = sprintf(
        "%d %ss receive a positive weight, and %d receive a negative weight.",
        ox$nr_plus,
        treat,
        ox$nr_minus
      )
      if (ox$tot_cells > ox$nr_plus + ox$nr_minus) {
        oweight_string = sprintf("%s\n%d (g,t) cells receive the treatment, but the %ss of %d cells receive a weight equal to zero.", oweight_string, ox$tot_cells, treat,ox$tot_cells - (ox$nr_plus + ox$nr_minus))
      }

      cat("\n\n")
      cat(oassumption_string)
      cat("\n")
      cat(oweight_string)
      cat("\n\n")
      print_treat_matrix(tmat = otmat, tvar = otvar, ttype = treat, otreat = TRUE)

    }
  }

  # print summary measures
  if (isTRUE(x$summary_measures)) {
    subscr = substr(x$type, 1, 2)
    cat("\n\n")
    cat(cli::style_bold("Summary Measures:"))
    cat("\n")
    cat(sprintf("  TWFE Coefficient (\U03B2_%s): %.4f", subscr, x$beta))
    if (!is.null(x$sensibility)) {
      cat("\n")
      cat(sprintf("  min \U03C3(\U0394) compatible with \U03B2_%s and \U0394_TR = 0: %.4f", subscr, x$sensibility))
      if (!is.null(x$sensibility2) && x$sum_minus < 0) {
        cat("\n")
        cat(sprintf("  min \U03C3(\U0394) compatible with treatment effect of opposite sign than \U03B2_%s in all (g,t) cells: %.4f", subscr, x$sensibility2))
      }
      cat("\n")
      cat("  Reference: Corollary 1, de Chaisemartin, C and D'Haultfoeuille, X (2020a)")
    }
  }

  #print random weights
  if (!is.null(x$random_weights)) {
    cat("\n\n")
    cat(cli::style_bold("Regression of variables possibly correlated with the treatment effect on the weights:"))
    cat("\n")
    print(x$mat)
  }

  cat("\n\n")
  cat(cli::style_italic("The development of this package was funded by the European Union (ERC, REALLYCREDIBLE,GA N. 101043899)."))
  cat("\n\n")

  return(invisible(x))
}

