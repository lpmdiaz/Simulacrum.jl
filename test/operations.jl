using Simulacrum
using HyperGraphs, Symbolics

# cloning one hypergraph
chx = ChemicalHyperGraph{Num}()
@test (clone(chx, 1) == chx) && !(clone(chx, 1) === chx)

# cloning n hypergraphs
@variables t X(t) Y(t) k
che = ChemicalHyperEdge([X], [Y], k)
n = rand(1:100)
cloned_chxs = clone(ChemicalHyperGraph(che), n)
@test length(cloned_chxs) == n

# rename_weights, where all rates are symbolic variables
chxs = clone(ChemicalHyperGraph(che), n, rename_weights = true)
weight.([hyperedges(chx)[1] for chx in chxs])

# rename_weights, where all rates are integers (nothing should happen)
chxs = clone(ChemicalHyperGraph(ChemicalHyperEdge([X], [Y], 2)), n, rename_weights = true)
@test all(weight.([hyperedges(chx)[1] for chx in chxs]) .== 2)

# rename_weights, where some weights are symbolic variables and some weights are integers
chxs = clone(ChemicalHyperGraph([ChemicalHyperEdge([X], [Y], 2), ChemicalHyperEdge([X], [Y], k)]), n, rename_weights = true)
@test all(weight.([hyperedges(chx)[1] for chx in chxs]) .== 2)
weight.([hyperedges(chx)[2] for chx in chxs])
