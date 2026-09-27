function test_result(test_R::OrderedCollections.OrderedDict, test_julia::OrderedCollections.OrderedDict)
    for cc in intersect(keys(test_R), keys(test_julia)) 
        julia_content = test_julia[cc]
        R_content = test_R[cc]

        if julia_content isa Number
            @test julia_content ≈ R_content
        elseif julia_content isa DataFrame
            for col in names(julia_content)
                @test julia_content[!, col] ≈ R_content[!, col]
            end
        else
            @test julia_content == R_content
        end
    end
end

function test_result(test_R::DataFrames.DataFrame, test_julia::DataFrames.DataFrame)
    for cc in intersect(names(test_R), names(test_julia)) 
        julia_content = test_julia[!, cc]
        R_content = test_R[!, cc]
        @test julia_content ≈ R_content
    end
end

function check_keys(test_R, test_julia)
    failed = []

    for cc in intersect(keys(test_R), keys(test_julia))
        julia_content = test_julia[cc]
        R_content = test_R[cc]

        passed =
        if julia_content isa Number
            julia_content ≈ R_content    
        elseif julia_content isa DataFrame
            if ncol(julia_content) == ncol(R_content)
                all(julia_content[!, col] ≈ R_content[!, col]
                    for col in names(julia_content))
            else
                false
            end
        else
            julia_content == R_content
        end

        !passed && push!(failed, cc)
    end

    return failed
end

function check_cols(test_R, test_julia)
    failed = []

    for col in intersect(names(test_R), names(test_julia))
        julia_content = test_julia[:, col]
        R_content = test_R[:, col]

        passed =
        if length(julia_content) == length(R_content) 
            julia_content ≈ R_content
        else
            false
        end

        !passed && push!(failed, col)
    end

    return failed
end

function df_isapprox(df1, df2; atol=1, rtol=0)
    names(df1) == names(df2) || return false
    size(df1) == size(df2) || return false

    for col in names(df1)
        x = df1[!, col]
        y = df2[!, col]

        for i in eachindex(x, y)
            xi, yi = x[i], y[i]

            # Both missing → equal
            if ismissing(xi) && ismissing(yi)
                continue

            # One missing → different
            elseif ismissing(xi) || ismissing(yi)
                return false

            # Numbers → approximate comparison
            elseif xi isa Number && yi isa Number
                if !isapprox(xi, yi; atol=atol, rtol=rtol)
                    return false
                end

            # Everything else → exact comparison
            elseif xi != yi
                return false
            end
        end
    end

    return true
end


function compare_df(df1, df2; atol=1e-8, rtol=1e-8)
    names(df1) == names(df2) || return (:names, nothing)
    size(df1) == size(df2) || return (:size, nothing)

    for col in names(df1)
        x = df1[!, col]
        y = df2[!, col]

        for i in eachindex(x, y)
            xi, yi = x[i], y[i]

            if ismissing(xi) && ismissing(yi)
                continue
            elseif ismissing(xi) || ismissing(yi)
                return (:missing, (col, i, xi, yi))
            elseif xi isa Number && yi isa Number
                if !isapprox(xi, yi; atol=atol, rtol=rtol)
                    return (:value, (col, i, xi, yi, xi - yi))
                end
            elseif xi != yi
                return (:value, (col, i, xi, yi))
            end
        end
    end

    return nothing
end
