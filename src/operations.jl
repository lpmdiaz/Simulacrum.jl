# clone a given ChemicalHyperGraph{Num} n times
# the symbolic variables will be renamed with a susbscript going from 1 to n
# note: set rename_weights to true to also rename parameters in the same way
function clone(hg::ChemicalHyperGraph{Num}, n::Int; rename_weights = false)

    # initialise an empty vector that will hold the cloned hypergraphs
    n == 1 ? (return deepcopy(hg)) : (hypergraphs = Vector{ChemicalHyperGraph{Num}}(undef, n))

    # iteration over clones
    for i in 1:n

        # define new vertices
        new_vs = subscript_vars(vertices(hg), i)
        v_d = Dict(old_v => new_v for (old_v, new_v) in zip(vertices(hg), new_vs)) # dictionary to keep track of changes

        # rename weights, if needed
        if rename_weights
            old_ws = rate.(hyperedges(hg))
            new_ws = Vector{Any}(undef, length(old_ws))
            iswsym = [(w isa Num && get_value(w) isa Symbolic) for w in old_ws] # check which weights are symbolic variables
            [new_ws[k] = (iswsym[k] ? subscript_var(old_ws[k], i) : old_ws[k]) for k in 1:length(old_ws)]
            w_d = Dict(old_w => new_w for (old_w, new_w) in zip(old_ws, new_ws)) # dictionary to keep track of changes
        end

        # define new hyperedges
        new_hes = Vector{ChemicalHyperEdge{Num}}(undef, nhe(hg))
        for (j, he) in enumerate(hyperedges(hg))
            new_he = deepcopy(he)
            replace!(v -> isa(get_value(v), Symbolic) ? v_d[v] : v, src(new_he))
            replace!(v -> isa(get_value(v), Symbolic) ? v_d[v] : v, tgt(new_he))
            rename_weights && (new_he.weight = w_d[rate(new_he)])
            new_hes[j] = new_he
        end

        hypergraphs[i] = ChemicalHyperGraph(new_vs, new_hes)

    end

    hypergraphs

end
