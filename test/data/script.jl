function data_official_test_1_download()
    url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Wolfers%202006/wolfers2006_didtextbook.dta"
    tmp = Downloads.download(url)
    data = ReadStatTables.readstat(tmp)
    data = DataFrames.DataFrame(data)
    CSV.write("./test/data/2_official_test_1_data.csv", data)
end

function data_official_test_2_download()
    url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Pierce%20and%20Schott%202016/pierce_schott_didtextbook.dta"
    tmp = Downloads.download(url)
    data = ReadStatTables.readstat(tmp)
    data = DataFrames.DataFrame(data)

    data_1 = DataFrames.DataFrame(indusid = data.indusid, time = 1, Y = 0, D = 0)
    data_2 = DataFrames.DataFrame(indusid = data.indusid, time = 2, Y = data.delta2001, D = data.ntrgap)
    data = [data_1; data_2]
    
    CSV.write("./test/data/2_official_test_2_data.csv", data)
end

function original_data_official_test_3_download()
    url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Gentzkow%20et%20al%202011/gentzkowetal_didtextbook.RData"
    tmp = Downloads.download(url)
    obj = RData.load(tmp)
    data = obj["df"]
    data = DataFrames.DataFrame(data)
    RCall.@rput data

    # Credit: Anzony Quispe
    RCall.rcopy(R"
        df <- fastDummies::dummy_cols(data, select_columns = 'styr', remove_first_dummy = FALSE)
        df <- fastDummies::dummy_cols(df, select_columns = 'styr',
                remove_first_dummy = FALSE,
                remove_selected_columns = FALSE)
        
        # Crear dummies
        styr_dummies <- model.matrix(~factor(df$styr) - 1)
        colnames(styr_dummies) <- paste0('styr_', levels(factor(df$styr)))
        styr_cols <- paste0('styr_', levels(factor(df$styr)))
        
        # Unirlas al dataframe original
        df <- cbind(df, styr_dummies)
        utils::write.csv(df, file.path('.', 'test', 'data', '2_official_test_3_data_original.csv'), row.names = FALSE)
    ")
end

function alternative_data_official_test_3_download()
    url = "https://raw.githubusercontent.com/anzonyquispe/did_book/main/cc_xd_didtextbook_2025_9_30/Data%20sets/Gentzkow%20et%20al%202011/gentzkowetal_didtextbook.RData"
    tmp = Downloads.download(url)
    obj = RData.load(tmp)
    data = obj["df"]
    data = DataFrames.DataFrame(data)
    RCall.@rput data

    RCall.rcopy(R"
        df <- data
        df <- cbind(
        df,
        model.matrix(~ factor(styr) - 1, data = df) |>
            as.data.frame() |>
            setNames(paste0(\"styr_\", levels(factor(df$styr))))
        )

        utils::write.csv(
            df,
            \"./test/data/2_official_test_3_data_original.csv\",
            row.names = FALSE
        )
    ")
    data = RCall.rcopy(R"df")
    CSV.write("./test/data/2_official_test_3_data_alternative.csv", data)
end

# Work in progress...
function test_3_comparison()
    original = CSV.read("./test/data/2_official_test_3_data_original.csv", DataFrames.DataFrame)
    alternative = CSV.read("./test/data/2_official_test_3_data_alternative.csv", DataFrames.DataFrame)

    test_result(original, alternative)

    for col in names(original)
        test_resultat = original[!, col] == alternative[!, col]
        if test_resultat
            print("No problem with ", col, "\n")
        else
            print("Problem wit ", col, "\n")
        end
    end

    original[!, :prestout]
    alternative[!, :prestout]

    names(original) == names(alternative)

end

function test_data_prepare()
    data_official_test_1_download()
    data_official_test_2_download()
    original_data_official_test_3_download()
end