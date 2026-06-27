
## Custom print print method for treatment matrix
function print_treat_matrix(;tmat, tvar, ttype, otreat = false)

    tmat = DataFrames.DataFrame(tmat, :auto)
    tmat_row_names = ["Positive weights", "Negative weights", "Total"]
    tmat.row_names = tmat_row_names

    if otreat 
        tstring = string("Other treat.: ", replace(tvar, "^OT" => ""))
    else
        tstring = "Treat. var:" .* tvar
    end

    tmat_titles = [tstring, string(ttype, "s"), string("\U03A3", " weights")]
    tmat = rename(tmat, tmat_titles)
    tmat = select(tmat, tmat_titles[3], tmat_titles[1], tmat_titles[2])
    
    # Style for the table: 
    table_format = PrettyTables.TextTableFormat(; PrettyTables.@text__no_vertical_lines)
    title = "Treatment matrix"
    highlighters = [
        PrettyTables.TextHighlighter((data, i, j) -> (i == 2) && (j ∈ [2, 3]) && (data[i, j] != 0), crayon"fg:red")
    ]

    table_str = sprint() do io
        PrettyTables.pretty_table(
            io,
            tmat;
            table_format,
            title,
            highlighters
        )
    end

    return table_str
end