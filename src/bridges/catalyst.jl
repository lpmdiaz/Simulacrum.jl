# convert a Reaction to a ChemicalHyperEdge
function Base.convert(::Type{ChemicalHyperEdge}, r::Catalyst.Reaction)
    t_subs = eltype(r.substrates)
    t_prods = eltype(r.products)
    t = (isequal(t_subs, t_prods) ? t_subs : Simulacrum.get_lowest_subtype(t_subs, t_prods))
    ChemicalHyperEdge(SpeciesSet(Vector{t}(r.substrates), r.substoich), SpeciesSet(Vector{t}(r.products), r.prodstoich), r.rate)
end
function Base.convert(::Type{ChemicalHyperEdge}, rs::AbstractVector{T}) where {T<:Catalyst.Reaction}
    convert.(ChemicalHyperEdge, rs)
end

# now these functions may be defined via the conversion defined above
isunimolecular(r::Catalyst.Reaction) = isunimolecular(convert(ChemicalHyperEdge, r))
ismultimolecular(r::Catalyst.Reaction) = !(isunimolecular(r))

# convert a ChemicalHyperEdge to a Reaction
# note that rate(che)[1] is needed -- not ideal
function Base.convert(::Type{Catalyst.Reaction}, che::ChemicalHyperEdge)
    Reaction(rate(che)[1], src(che), tgt(che), src_stoich(che), tgt_stoich(che))
end
function Base.convert(::Type{Catalyst.Reaction}, ches::AbstractVector{T}) where {T<:ChemicalHyperEdge}
    convert.(Catalyst.Reaction, ches)
end

# convert a ReactionSystem to a ChemicalHyperGraph
function Base.convert(::Type{ChemicalHyperGraph}, rsys::Catalyst.ReactionSystem)
    ChemicalHyperGraph(convert(ChemicalHyperEdge, equations(rsys)))
end

# return reactions from a chemical hypergraph
catalyst_reactions(chg::ChemicalHyperGraph) = convert(Catalyst.Reaction, hyperedges(chg))

# convert a ChemicalHyperGraph to a ReactionSystem
function Base.convert(::Type{Catalyst.ReactionSystem}, chg::ChemicalHyperGraph; p = [], iv = Symbolics.variable(:t))
    Catalyst.ReactionSystem(catalyst_reactions(chg), iv, vertices(chg), p, name = :rsys)
end

# overload the ChemicalHyperGraph constructor to Reaction and ReactionSystem types
ChemicalHyperGraph(r::Catalyst.Reaction) = ChemicalHyperGraph(convert(ChemicalHyperEdge, r))
function ChemicalHyperGraph(rs::AbstractVector{T}) where {T<:Catalyst.Reaction}
    ChemicalHyperGraph(convert(ChemicalHyperEdge, rs))
end
ChemicalHyperGraph(rsys::Catalyst.ReactionSystem) = convert(ChemicalHyperGraph, rsys)
