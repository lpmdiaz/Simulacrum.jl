using Simulacrum
using HyperGraphs, Symbolics
const ChE = ChemicalHyperEdge
const ChX = ChemicalHyperGraph

intvars = [1, 2, 3]
symvars = @variables X Y Z

@test all(length.(vertices.(Simulacrum.connect(intvars, ChE, AllToAll))) .== 3)
@test all(length.(vertices.(Simulacrum.connect(symvars, ChE, AllToAll))) .== 3)
@test all(length.(vertices.(Simulacrum.connect(intvars, ChE, AllToAll, to_hyperedge_idx = false))) .== 2)
@test all(length.(vertices.(Simulacrum.connect(symvars, ChE, AllToAll, to_hyperedge_idx = false))) .== 2)
@test all(length.(vertices.(Simulacrum.connect(intvars, ChE, Cycle))) .== 2)
@test all(length.(vertices.(Simulacrum.connect(symvars, ChE, Cycle))) .== 2)
@test all(length.(vertices.(Simulacrum.connect(intvars, ChE, Cycle, to_hyperedge_idx = false))) .== 2)
@test all(length.(vertices.(Simulacrum.connect(symvars, ChE, Cycle, to_hyperedge_idx = false))) .== 2)
@test all(length.(vertices.(Simulacrum.connect(intvars, ChE, Path))) .== 2)
@test all(length.(vertices.(Simulacrum.connect(symvars, ChE, Path))) .== 2)
@test all(length.(vertices.(Simulacrum.connect(intvars, ChE, Path, to_hyperedge_idx = false))) .== 2)
@test all(length.(vertices.(Simulacrum.connect(symvars, ChE, Path, to_hyperedge_idx = false))) .== 2)

template_che = ChE(SpeciesSet(10, 2), SpeciesSet(20, 1), 3)
connected = Simulacrum.connect(intvars, template_che, Cycle)
@test all(vcat(src_stoich.(connected)...) .== src_stoich(template_che) .== 2)
@test all(vcat(tgt_stoich.(connected)...) .== tgt_stoich(template_che) .== 1)
@test all(weight.(connected) .== weight(template_che) .== 3)

template_che = ChE(SpeciesSet(X, 2), SpeciesSet(X, 1), 3)
connected = Simulacrum.connect(symvars, template_che, Cycle)
@test all(vcat(src_stoich.(connected)...) .== src_stoich(template_che) .== 2)
@test all(vcat(tgt_stoich.(connected)...) .== tgt_stoich(template_che) .== 1)
@test all(weight.(connected) .== weight(template_che) .== 3)

@test Simulacrum.connect!(ChX(intvars, ChE{Int64}[]), intvars, ChE, Cycle)
@test Simulacrum.connect!(ChX(intvars, ChE{Int64}[]), intvars, ChE, Cycle, to_hyperedge_idx = false)
@test Simulacrum.connect!(ChX(symvars, ChE{Num}[]), symvars, ChE, Cycle)
@test Simulacrum.connect!(ChX(symvars, ChE{Num}[]), symvars, ChE, Cycle, to_hyperedge_idx = false)
chx = ChX(symvars, ChE{Num}[])
@test Simulacrum.connect!(chx, symvars, ChE, AllToAll)
@test nhe(chx) == 3
chx = ChX(symvars, ChE{Num}[])
@test Simulacrum.connect!(chx, symvars, ChE, Cycle)
@test nhe(chx) == 3
chx = ChX(symvars, ChE{Num}[])
@test Simulacrum.connect!(chx, symvars, ChE, Path)
@test nhe(chx) == 2

template_che = ChE(SpeciesSet(10, 2), SpeciesSet(20, 1), 3)
chx = ChX(intvars, ChE{Int64}[])
@test Simulacrum.connect!(chx, intvars, template_che, Cycle)
@test all(weight.(hyperedges(chx)) .== weight(template_che) .== 3)
chx = ChX(intvars, ChE{Int64}[])
@test Simulacrum.connect!(chx, intvars, template_che, AllToAll, to_hyperedge_idx = false)
@test all(weight.(hyperedges(chx)) .== weight(template_che) .== 3)
@test nhe(chx) == 6
template_che = ChE(SpeciesSet(X, 2), SpeciesSet(X, 1), 3)
chx = ChX(symvars, ChE{Num}[])
@test Simulacrum.connect!(chx, symvars, template_che, Cycle)
@test all(weight.(hyperedges(chx)) .== weight(template_che) .== 3)
chx = ChX(symvars, ChE{Num}[])
@test Simulacrum.connect!(chx, symvars, template_che, AllToAll, to_hyperedge_idx = false)
@test all(weight.(hyperedges(chx)) .== weight(template_che) .== 3)
@test nhe(chx) == 6

# same as connect but adds the source vertex in the target set, and so the number of vertices is same as connect + 1
@test all(length.(vertices.(couple(intvars, ChE, AllToAll))) .== 4) # 3 + 1
@test all(length.(vertices.(couple(symvars, ChE, AllToAll))) .== 4) # 3 + 1
@test all(length.(vertices.(couple(intvars, ChE, Cycle))) .== 3) # 2 + 1
@test all(length.(vertices.(couple(symvars, ChE, Cycle))) .== 3) # 2 + 1
@test all(length.(vertices.(couple(intvars, ChE, Path))) .== 3) # 2 + 1
@test all(length.(vertices.(couple(symvars, ChE, Path))) .== 3) # 2 + 1
