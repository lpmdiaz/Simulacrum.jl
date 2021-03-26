# convert a Reaction to a ChemicalHyperEdge
function Base.convert(::Type{ChemicalHyperEdge}, r::ModelingToolkit.Reaction)
    t_subs = eltype(r.substrates)
    t_prods = eltype(r.products)
    t = (isequal(t_subs, t_prods) ? t_subs : Simulacrum.get_lowest_subtype(t_subs, t_prods))
    ChemicalHyperEdge(SpeciesSet(Vector{t}(r.substrates), r.substoich), SpeciesSet(Vector{t}(r.products), r.prodstoich), r.rate)
end
function Base.convert(::Type{ChemicalHyperEdge}, rs::AbstractVector{T}) where {T<:ModelingToolkit.Reaction}
    convert.(ChemicalHyperEdge, rs)
end

# now these functions may be defined via the conversion defined above
isunimolecular(r::ModelingToolkit.Reaction) = isunimolecular(convert(ChemicalHyperEdge, r))
ismultimolecular(r::ModelingToolkit.Reaction) = !(isunimolecular(r))

# convert a ChemicalHyperEdge to a Reaction
# note that rate(che)[1] is needed -- not ideal
function Base.convert(::Type{ModelingToolkit.Reaction}, che::ChemicalHyperEdge)
    Reaction(rate(che)[1], src(che), tgt(che), src_stoich(che), tgt_stoich(che))
end
function Base.convert(::Type{ModelingToolkit.Reaction}, ches::AbstractVector{T}) where {T<:ChemicalHyperEdge}
    convert.(ModelingToolkit.Reaction, ches)
end

# convert a ReactionSystem to a ChemicalHyperGraph
function Base.convert(::Type{ChemicalHyperGraph}, rsys::ModelingToolkit.ReactionSystem)
    ChemicalHyperGraph(convert(ChemicalHyperEdge, equations(rsys)))
end

# return reactions from a chemical hypergraph
mtk_reactions(chg::ChemicalHyperGraph) = convert(ModelingToolkit.Reaction, hyperedges(chg))

# convert a ChemicalHyperGraph to a ReactionSystem
function Base.convert(::Type{ModelingToolkit.ReactionSystem}, chg::ChemicalHyperGraph; p = [], iv = Variable(:t))
    ModelingToolkit.ReactionSystem(mtk_reactions(chg), iv, vertices(chg), p)
end

# overload the ChemicalHyperGraph constructor to Reaction and ReactionSystem types
ChemicalHyperGraph(r::ModelingToolkit.Reaction) = ChemicalHyperGraph(convert(ChemicalHyperEdge, r))
function ChemicalHyperGraph(rs::AbstractVector{T}) where {T<:ModelingToolkit.Reaction}
    ChemicalHyperGraph(convert(ChemicalHyperEdge, rs))
end
ChemicalHyperGraph(rsys::ModelingToolkit.ReactionSystem) = convert(ChemicalHyperGraph, rsys)
