# check whether a reaction on a chemical hyperedge is uni- or multimolecular
isunimolecular(che::ChemicalHyperEdge) = nsrcs(che) <=1 && ntgts(che) <= 1
ismultimolecular(che::ChemicalHyperEdge) = !(isunimolecular(che))

# return two reactions (forward and backward) given some species and two rates
function reversible_reaction(s1, s2, rates::AbstractVector)
    length(rates) == 2 || error("too many rates given: expected 2, given $(length(rates))")
    fwd = ChemicalHyperEdge(s1, s2, rates[1])
    bwd = switch(fwd); update_weight!(bwd, rates[2])
    return [fwd, bwd]
end
reversible_reaction(che::ChemicalHyperEdge, rates::AbstractVector) = reversible_reaction(src(che), tgt(che), rates)

# macro to easily use the above
macro reversible(che, rates)
    return esc(:(reversible_reaction($che, $rates)))
end
