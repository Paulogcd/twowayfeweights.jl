@testset "utils.jl" begin
    
    # The utils.jl file has 11 different functions:
    # * fn_ctrl_rename
    # * get_controls_rename
    # * fn_treatment_rename
    # * get_treatments_rename
    # * fn_treatment_weight_rename
    # * fn_random_weight_rename
    # * get_random_weight_rename
    # * twowayfeweights_rename_var
    # * twowayfeweights_transform
    # * twowayfeweights_filter
    # * twowayfeweights_summarize_weights
    # * twowayfeweights_test_random_weights

    # To get all the functions from the original package.
    # R"ls(getNamespace('TwoWayFEWeights'))"

    include("utils_1.jl");
    include("utils_2.jl");
    include("utils_3.jl");
    include("utils_4.jl");
    include("utils_5.jl");
    include("utils_6.jl");
end;