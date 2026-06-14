# In the original R package, the authors define a specific class
# Here, I prefer a data struct wrapper, such that:
struct twowayfeweights
    data::OrderedDict{Any, Any} # Or use parametric types for better performance?
end

# We are also going to define a set of doable operations, so that the functions can work properly:
Base.getindex(nt::twowayfeweights, key)         = nt.data[key]
Base.setindex!(nt::twowayfeweights, v, key)     = (nt.data[key] = v)
Base.length(nt::twowayfeweights)                = length(nt.data)
Base.keys(x::twowayfeweights)                   = keys(x.data)
Base.iterate(nt::twowayfeweights)               = iterate(nt.data)
Base.iterate(nt::twowayfeweights, state)        = iterate(nt.data, state)

# Maybe to define:  ############################################

# Empty initialisator.
# function twowayfeweights()
#     # resultat = twowayfeweights(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
#     # resultat = twowayfeweights()
#     # return resultat
# end

# Conversion to OrderedDict
function OrderedCollections.OrderedDict(x::twowayfeweights)

    resultat = OrderedCollections.OrderedDict()
    for element in keys(x)
        resultat[Symbol(element)] = x.data[Symbol(element)]
    end

end