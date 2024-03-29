using Simulacrum
using HyperGraphs, Catalyst

# setting up some Catalyst Reaction and ChemicalHyperEdge variables
# r1 and r2 are equivalent to che1 and che2, respectively
@variables t X(t) Y(t) Z(t)
r1 = Reaction(2, [X], [Y])					# Catalyst reaction unimolecular
r2 = Reaction(2, [X, Y], [Z])				# Catalyst reaction multimolecular
che1 = ChemicalHyperEdge([X], [Y], 2)		# chemical hyperedge unimolecular
che2 = ChemicalHyperEdge([X, Y], [Z], 2)	# chemical hyperedge multimolecular
@named rsys = ReactionSystem([r1, r2], t, [X, Y, Z], [])
chx = ChemicalHyperGraph([che1, che2])

# testing equivalence
@test incidence_matrix(ChemicalHyperGraph(r1)) == incidence_matrix(ChemicalHyperGraph(che1))
@test incidence_matrix(chx) == incidence_matrix(ChemicalHyperGraph(rsys))

# conversions
@test convert(ChemicalHyperEdge, r1) == che1 && convert(ChemicalHyperEdge, r2) == che2
rx = [Reaction(1, nothing, [X]), Reaction(1, [Y], nothing)]
@test typeof(convert(ChemicalHyperEdge, rx)) == Vector{ChemicalHyperEdge{eltype(rx[1].products)}}
@test typeof(convert(Reaction, che1).substrates) == Vector{eltype(r1.substrates)}
@test eltype(convert(ChemicalHyperGraph, rsys)) == eltype(equations(rsys)[1].substrates)
catalyst_reactions(chx)
convert(ReactionSystem, chx)
ChemicalHyperGraph(r1)
ChemicalHyperGraph([r1, r2])
ChemicalHyperGraph(rsys)
convert(ODESystem, convert(ReactionSystem, chx))

# these convert reactions to chemical hyperedges under the hood
@test isunimolecular(r1) && ismultimolecular(r2)
@test !isunimolecular(r2) && !ismultimolecular(r1)
