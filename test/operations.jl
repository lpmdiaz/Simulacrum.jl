using Simulacrum
using HyperGraphs, Symbolics

# cloning one hypergraph
chg = ChemicalHyperGraph{Num}()
@test (clone(chg, 1) == chg) && !(clone(chg, 1) === chg)

# cloning n hypergraphs
@variables t X(t) Y(t) k
che = ChemicalHyperEdge([X], [Y], k)
n = rand(1:100)
cloned_chgs = clone(ChemicalHyperGraph(che), n)
@test length(cloned_chgs) == n

# rename_weights, where all rates are symbolic variables
chgs = clone(ChemicalHyperGraph(che), n, rename_weights = true)
weight.([hyperedges(chg)[1] for chg in chgs])

# rename_weights, where all rates are integers (nothing should happen)
chgs = clone(ChemicalHyperGraph(ChemicalHyperEdge([X], [Y], 2)), n, rename_weights = true)
@test all(weight.([hyperedges(chg)[1] for chg in chgs]) .== 2)

# rename_weights, where some weights are symbolic variables and some weights are integers
chgs = clone(ChemicalHyperGraph([ChemicalHyperEdge([X], [Y], 2), ChemicalHyperEdge([X], [Y], k)]), n, rename_weights = true)
@test all(weight.([hyperedges(chg)[1] for chg in chgs]) .== 2)
weight.([hyperedges(chg)[2] for chg in chgs])
