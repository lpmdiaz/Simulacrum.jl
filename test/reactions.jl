using Simulacrum
using HyperGraphs, Symbolics

@variables t X(t) Y(t) Z(t)
che1 = ChemicalHyperEdge([X], [Y], 2)		# chemical hyperedge unimolecular
che2 = ChemicalHyperEdge([X, Y], [Z], 2)	# chemical hyperedge multimolecular
@test isunimolecular(che1) && ismultimolecular(che2)
@test !isunimolecular(che2) && !ismultimolecular(che1)

# reversible reactions
@variables t A(t) B(t) C(t) k₁ k₂
fwd_bwd = reversible_reaction([A, B], [C], [k₁, k₂])
fwd = ChemicalHyperEdge([A, B], [C], k₁)
bwd = ChemicalHyperEdge([C], [A, B], k₂)
@test [fwd, bwd] == fwd_bwd
@test reversible_reaction(ChemicalHyperEdge([A, B], [C]), [k₁, k₂])[2] == bwd
@test (@reversible ChemicalHyperEdge([A, B], [C]) [k₁, k₂]) == [fwd, bwd]
@test reversible_reaction([A, B], [C], [k₁, k₂])[2] == bwd
