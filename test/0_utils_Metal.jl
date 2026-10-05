# Performing tests on MacOS machines, this allows to use Metal.jl during the tests.
using Metal
result_metal = Metal.functional()
method = result_metal ? :Metal : :cpu