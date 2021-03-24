using Simulacrum
using HyperGraphs, Symbolics

@variables t X(t) Y(t) Z(t)
che1 = ChemicalHyperEdge([X], [Y], 2)		# chemical hyperedge unimolecular
che2 = ChemicalHyperEdge([X, Y], [Z], 2)	# chemical hyperedge multimolecular

@test isunimolecular(che1) && ismultimolecular(che2)
@test !isunimolecular(che2) && !ismultimolecular(che1)
