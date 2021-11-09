# clone a given ChemicalHyperGraph{Num} n times
# the symbolic variables will be renamed with a susbscript going from 1 to n
# note: set rename_weights to true to also rename parameters in the same way
function clone(chx::ChemicalHyperGraph{Num}, n::Int; rename_weights = false)

    # initialise an empty vector that will hold the cloned hypergraphs
    n == 1 ? (return deepcopy(chx)) : (hypergraphs = Vector{ChemicalHyperGraph{Num}}(undef, n))

    # iteration over clones
    for i in 1:n

        # define new vertices
        new_vs = subscript_vars(vertices(chx), i)
        v_d = Dict(old_v => new_v for (old_v, new_v) in zip(vertices(chx), new_vs)) # dictionary to keep track of changes

        # rename weights, if needed
        if rename_weights
            old_ws = rate.(hyperedges(chx))
            new_ws = Vector{Any}(undef, length(old_ws))
            iswsym = [(w isa Num && get_value(w) isa Symbolic) for w in old_ws] # check which weights are symbolic variables
            [new_ws[k] = (iswsym[k] ? subscript_var(old_ws[k], i) : old_ws[k]) for k in 1:length(old_ws)]
            w_d = Dict(old_w => new_w for (old_w, new_w) in zip(old_ws, new_ws)) # dictionary to keep track of changes
        end

        # define new hyperedges
        new_es = Vector{ChemicalHyperEdge{Num}}(undef, nhe(chx))
        for (j, e) in enumerate(hyperedges(chx))
            new_e = deepcopy(e)
            replace!(v -> isa(get_value(v), Symbolic) ? v_d[v] : v, src(new_e))
            replace!(v -> isa(get_value(v), Symbolic) ? v_d[v] : v, tgt(new_e))
            rename_weights && (new_e.weight = w_d[rate(new_e)])
            new_es[j] = new_e
        end

        hypergraphs[i] = ChemicalHyperGraph(new_vs, new_es)

    end

    hypergraphs

end
