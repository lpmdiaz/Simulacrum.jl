# returns a vector of oriented hyperedges of hyperedgetype type connecting the given vertices according to the given pattern
@traitfn function connect(vs::Vector, hyperedgetype::Type{T}, pattern::Type{<:AbstractPattern}; to_hyperedge_idx = true, kwargs...) where {T<:AbstractHyperEdge; IsOriented{T}}

    # make edge indices that will connect the input vertices into the input pattern
    idx = indices(pattern(length(vs), kwargs...))

    # if needed, convert those indices to hyperedge indices
    to_hyperedge_idx && (idx = edge_idx_to_hyperedge_idx(idx))

    # initialise a vector that will hold the new hyperedges
    connections = Vector{T{eltype(vs)}}(undef, length(idx))

    for (i, e_idx) in enumerate(idx)

        # build source and target sets from the indices
        src_vs, tgt_vs = vs[first(e_idx)], vs[last(e_idx)]

        # if using ordinary edge indices (where cardinality is 2), need to wrap those sets into vectors for the hyperedge constructor to accept them
        !to_hyperedge_idx && (src_vs = [src_vs]; tgt_vs = [tgt_vs])

        # make and assign the new hyperedge
        @inbounds connections[i] = T(src_vs, tgt_vs)

    end

    connections

end

# similar to the other implementation of connect just above, but here information in template_hyperedge is kept (multiplicities and weight)
@traitfn function connect(vs::Vector, template_hyperedge::T, pattern::Type{<:AbstractPattern}; to_hyperedge_idx = true) where {T<:AbstractHyperEdge; IsOriented{T}}

    # make edge indices that will connect the input vertices into the input pattern
    idx = indices(pattern(length(vs)))

    # if needed, convert those indices to hyperedge indices
    to_hyperedge_idx && (idx = edge_idx_to_hyperedge_idx(idx))

    # initialise a vector that will hold the new hyperedges
    connections = Vector{T}(undef, length(idx))

    for (i, e_idx) in enumerate(idx)

        # build source and target sets from the indices
        src_vs, tgt_vs = vs[first(e_idx)], vs[last(e_idx)]

        # if using ordinary edge indices (where cardinality is 2), need to wrap those sets into vectors for the hyperedge constructor to accept them
        !to_hyperedge_idx && (src_vs = [src_vs]; tgt_vs = [tgt_vs])

        # make the new hyperedge
        if !isempty(template_hyperedge) # retain information in template_hyperedge
            e = deepcopy(template_hyperedge)
            e.src.objs = src_vs
            e.tgt.objs = tgt_vs
        else
            e = T(src_vs, tgt_vs, weight(template_hyperedge)) # in case weight has information
        end

        @inbounds connections[i] = e

    end

    connections

end

# similar as above but adds the connections from connect to the given hypergraph
function connect!(hypergraph::T, vs::Vector, hyperedge::Union{U, Type{U}}, pattern::Type{<:AbstractPattern}; to_hyperedge_idx = true, kwargs...) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    !has_vertices(hypergraph, vs) && error("not all vertices in hypergraph")
    connections = connect(vs, hyperedge, pattern, to_hyperedge_idx = to_hyperedge_idx, kwargs...)
    add_hyperedges!(hypergraph, connections)
end

# couple function; based on connect() but adds source in the target set
@traitfn function couple(vs::Vector, template_hyperedge::Type{T}, pattern::Type{<:AbstractPattern}; kwargs...) where {T<:AbstractHyperEdge; IsOriented{T}}
    idx = edge_idx_to_hyperedge_idx(indices(pattern(length(vs), kwargs...)))
    couplings = Vector{T{eltype(vs)}}(undef, length(idx))
    for (i, e_idx) in enumerate(idx)
        @inbounds couplings[i] = T(vs[first(e_idx)], vcat(vs[first(e_idx)], vs[last(e_idx)]))
    end
    couplings
end
