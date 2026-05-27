# In the original R package, the authors define a specific class
# Struct wrapper: 
struct twowayfeweights
    data::OrderedDict{Any, Any} # Or use parametric types for better performance
end

twowayfeweights_res = twowayfeweights(res)

Base.getindex(nt::twowayfeweights, key)         = nt.data[key]
Base.setindex!(nt::twowayfeweights, v, key)     = (nt.data[key] = v)
Base.length(nt::twowayfeweights)                = length(nt.data)
Base.keys(x::twowayfeweights)                   = keys(x.data)

# Iteration needs to return Pair{K, V}
Base.iterate(nt::twowayfeweights) = iterate(nt.data)
Base.iterate(nt::twowayfeweights, state) = iterate(nt.data, state)

# Empty initialisator.
function twowayfeweights()
    # resultat = twowayfeweights(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    # resultat = twowayfeweights()
    # return resultat
end

# Conversion to OrderedDict
function OrderedDic(x::twowayfeweights)

    base = twowayfeweights()
    for element in keys(x)

        twowayfeweights[Symbol(element)] = x[Symbol(element)]
    end

end