function test_result(test_R, test_julia)
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