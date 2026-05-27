
## Custom print print method for treatment matrix
# print_treat_matrix = function(tmat, tvar, ttype, otreat = FALSE) {
function print_treat_matrix(;tmat, tvar, ttype, otreat = false)

    # tmat = [
    #     ["Positive weights", "Negative weights", "Total"]
    #     tmat
    # ]
    tmat = DataFrames.DataFrame(tmat, :auto)
    tmat_row_names = ["Positive weights", "Negative weights", "Total"]
    tmat.row_names = tmat_row_names

    if otreat 
        tstring = string("Other treat.: ", replace(tvar, "^OT" => ""))
    else
        tstring = "Treat. var:" .* tvar
    end

    tmat_titles = [tstring, string(ttype, "s"), string("\U03A3", " weights")]
    tmat_tmp = rename(tmat, tmat_titles)

    # Calculate the width for each column
    # col_widths = apply(tmat, 2, function(x) max(nchar(x)))
    col_widths = max(ncol(tmat))

    # Create the header and separator line
    header = format_row(row = tmat[1], col_widths = col_widths)
    # header = tmat[1, ]
    
    # Calculate the separator line width
    # separator_line_width = nchar(header)

    # Print separator line before header
    @info(header, "\n")
    
    # Print the body of the matrix except the last row
    for i in 2:(nrow(tmat) - 1)
        print(format_row(row = tmat[i, :], col_widths = col_widths)), "\n" # See if it really is readable.
    end

    # Print separator line before last row
    # cat(cli::rule(width = separator_line_width), "\n")
    # Print the last row
    # cat(format_row(tmat[nrow(tmat), ]), "\n")
    format_row(row = tmat[nrow(tmat)], col_widths = col_widths)
    # @info(tmat[end,:], "\n")
    # Print separator line after last row
    # cat(cli::rule(width = separator_line_width))

end


# Function to format a single row based on column widths
function format_row(;row::Any, col_widths::Any)
    formatted_elements = map(eachindex(row)) do idx
        x = row[idx]
        width = col_widths[idx]
        
        if idx == 1
            # Left-align: negative width in Printf dynamic formatting
            # Note: Printf needs a literal format string, so we construct it or use lpad/rpad
            lpad(x, width) # Actually, lpad is right-aligned, rpad is left-aligned
        else
            # Right-align
            rpad(x, width)
        end
    end
    
    return join(formatted_elements, "    ")
end