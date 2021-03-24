# check whether a reaction on a chemical hyperedge is uni- or multimolecular
isunimolecular(che::ChemicalHyperEdge) = nsrcs(che) <=1 && ntgts(che) <= 1
ismultimolecular(che::ChemicalHyperEdge) = !(isunimolecular(che))
