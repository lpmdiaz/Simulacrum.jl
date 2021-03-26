# returns a vector of oriented hyperedges of hyperedgetype type connecting the given vertices according to the given pattern
@traitfn function connect(vx::Vector, hyperedgetype::Type{T}, pattern::Type{<:AbstractPattern}; to_hyperedge_idx = true, kwargs...) where {T<:AbstractHyperEdge; IsOriented{T}}

    # make edge indices that will connect the input vertices into the input pattern
    idx = indices(pattern(length(vx), kwargs...))

    # if needed, convert those indices to hyperedge indices
    to_hyperedge_idx && (idx = edge_idx_to_hyperedge_idx(idx))

    # initialise a vector that will hold the new hyperedges
    connections = Vector{T{eltype(vx)}}(undef, length(idx))

    for (i, he_idx) in enumerate(idx)

        # build source and target sets from the indices
        src_vx, tgt_vx = vx[first(he_idx)], vx[last(he_idx)]

        # if using ordinary edge indices (where cardinality is 2), need to wrap those sets into vectors for the hyperedge constructor to accept them
        !to_hyperedge_idx && (src_vx = [src_vx]; tgt_vx = [tgt_vx])

        # make and assign the new hyperedge
        @inbounds connections[i] = T(src_vx, tgt_vx)

    end

    connections

end

# similar to the other implementation of connect just above, but here information in template_hyperedge is kept (multiplicities and weight)
@traitfn function connect(vx::Vector, template_hyperedge::T, pattern::Type{<:AbstractPattern}; to_hyperedge_idx = true) where {T<:AbstractHyperEdge; IsOriented{T}}

    # make edge indices that will connect the input vertices into the input pattern
    idx = indices(pattern(length(vx)))

    # if needed, convert those indices to hyperedge indices
    to_hyperedge_idx && (idx = edge_idx_to_hyperedge_idx(idx))

    # initialise a vector that will hold the new hyperedges
    connections = Vector{T}(undef, length(idx))

    for (i, he_idx) in enumerate(idx)

        # build source and target sets from the indices
        src_vx, tgt_vx = vx[first(he_idx)], vx[last(he_idx)]

        # if using ordinary edge indices (where cardinality is 2), need to wrap those sets into vectors for the hyperedge constructor to accept them
        !to_hyperedge_idx && (src_vx = [src_vx]; tgt_vx = [tgt_vx])

        # make the new hyperedge
        if !isempty(template_hyperedge) # retain information in template_hyperedge
            he = deepcopy(template_hyperedge)
            he.src.objs = src_vx
            he.tgt.objs = tgt_vx
        else
            he = T(src_vx, tgt_vx, weight(template_hyperedge)) # in case weight has information
        end

        @inbounds connections[i] = he

    end

    connections

end

# similar as above but adds the connections from connect to the given hypergraph
function connect!(hypergraph::T, vx::Vector, hyperedge::Union{U, Type{U}}, pattern::Type{<:AbstractPattern}; to_hyperedge_idx = true, kwargs...) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    !has_vertices(hypergraph, vx) && error("not all vertices in hypergraph")
    connections = connect(vx, hyperedge, pattern, to_hyperedge_idx = to_hyperedge_idx, kwargs...)
    add_hyperedges!(hypergraph, connections)
end

# couple function; based on connect() but adds source in the target set
@traitfn function couple(vx::Vector, template_hyperedge::Type{T}, pattern::Type{<:AbstractPattern}; kwargs...) where {T<:AbstractHyperEdge; IsOriented{T}}
    idx = edge_idx_to_hyperedge_idx(indices(pattern(length(vx), kwargs...)))
    couplings = Vector{T{eltype(vx)}}(undef, length(idx))
    for (i, he_idx) in enumerate(idx)
        @inbounds couplings[i] = T(vx[first(he_idx)], vcat(vx[first(he_idx)], vx[last(he_idx)]))
    end
    couplings
end
