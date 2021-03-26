using Simulacrum
using HyperGraphs, Symbolics
const CHG = ChemicalHyperGraph
const CHE = ChemicalHyperEdge

intvars = [1, 2, 3]
@variables X Y Z
symvars = [X, Y, Z]

@test all(length.(vertices.(connect(intvars, CHE, AllToAll))) .== 3)
@test all(length.(vertices.(connect(symvars, CHE, AllToAll))) .== 3)
@test all(length.(vertices.(connect(intvars, CHE, AllToAll, to_hyperedge_idx = false))) .== 2)
@test all(length.(vertices.(connect(symvars, CHE, AllToAll, to_hyperedge_idx = false))) .== 2)
@test all(length.(vertices.(connect(intvars, CHE, Cycle))) .== 2)
@test all(length.(vertices.(connect(symvars, CHE, Cycle))) .== 2)
@test all(length.(vertices.(connect(intvars, CHE, Cycle, to_hyperedge_idx = false))) .== 2)
@test all(length.(vertices.(connect(symvars, CHE, Cycle, to_hyperedge_idx = false))) .== 2)
@test all(length.(vertices.(connect(intvars, CHE, Path))) .== 2)
@test all(length.(vertices.(connect(symvars, CHE, Path))) .== 2)
@test all(length.(vertices.(connect(intvars, CHE, Path, to_hyperedge_idx = false))) .== 2)
@test all(length.(vertices.(connect(symvars, CHE, Path, to_hyperedge_idx = false))) .== 2)

template_che = CHE(SpeciesSet(10, 2), SpeciesSet(20, 1), 3)
connected = connect(intvars, template_che, Cycle)
@test all(vcat(src_stoich.(connected)...) .== src_stoich(template_che) .== 2)
@test all(vcat(tgt_stoich.(connected)...) .== tgt_stoich(template_che) .== 1)
@test all(weight.(connected) .== weight(template_che) .== 3)

template_che = CHE(SpeciesSet(X, 2), SpeciesSet(X, 1), 3)
connected = connect(symvars, template_che, Cycle)
@test all(vcat(src_stoich.(connected)...) .== src_stoich(template_che) .== 2)
@test all(vcat(tgt_stoich.(connected)...) .== tgt_stoich(template_che) .== 1)
@test all(weight.(connected) .== weight(template_che) .== 3)

@test connect!(CHG(intvars, CHE{Int64}[]), intvars, CHE, Cycle)
@test connect!(CHG(intvars, CHE{Int64}[]), intvars, CHE, Cycle, to_hyperedge_idx = false)
@test connect!(CHG(symvars, CHE{Num}[]), symvars, CHE, Cycle)
@test connect!(CHG(symvars, CHE{Num}[]), symvars, CHE, Cycle, to_hyperedge_idx = false)
chg = CHG(symvars, CHE{Num}[])
@test connect!(chg, symvars, CHE, AllToAll)
@test nhe(chg) == 3
chg = CHG(symvars, CHE{Num}[])
@test connect!(chg, symvars, CHE, Cycle)
@test nhe(chg) == 3
chg = CHG(symvars, CHE{Num}[])
@test connect!(chg, symvars, CHE, Path)
@test nhe(chg) == 2

template_che = CHE(SpeciesSet(10, 2), SpeciesSet(20, 1), 3)
chg = CHG(intvars, CHE{Int64}[])
@test connect!(chg, intvars, template_che, Cycle)
@test all(weight.(hyperedges(chg)) .== weight(template_che) .== 3)
chg = CHG(intvars, CHE{Int64}[])
@test connect!(chg, intvars, template_che, AllToAll, to_hyperedge_idx = false)
@test all(weight.(hyperedges(chg)) .== weight(template_che) .== 3)
@test nhe(chg) == 6
template_che = CHE(SpeciesSet(X, 2), SpeciesSet(X, 1), 3)
chg = CHG(symvars, CHE{Num}[])
@test connect!(chg, symvars, template_che, Cycle)
@test all(weight.(hyperedges(chg)) .== weight(template_che) .== 3)
chg = CHG(symvars, CHE{Num}[])
@test connect!(chg, symvars, template_che, AllToAll, to_hyperedge_idx = false)
@test all(weight.(hyperedges(chg)) .== weight(template_che) .== 3)
@test nhe(chg) == 6

# same as connect but adds the source vertex in the target set, and so the number of vertices is same as connect + 1
@test all(length.(vertices.(couple(intvars, CHE, AllToAll))) .== 4) # 3 + 1
@test all(length.(vertices.(couple(symvars, CHE, AllToAll))) .== 4) # 3 + 1
@test all(length.(vertices.(couple(intvars, CHE, Cycle))) .== 3) # 2 + 1
@test all(length.(vertices.(couple(symvars, CHE, Cycle))) .== 3) # 2 + 1
@test all(length.(vertices.(couple(intvars, CHE, Path))) .== 3) # 2 + 1
@test all(length.(vertices.(couple(symvars, CHE, Path))) .== 3) # 2 + 1
