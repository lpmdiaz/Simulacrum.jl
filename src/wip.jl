module Wip
using Simulacrum
using HyperGraphs, Symbolics, ModelingToolkit

export mass_action, power_law, combinatoric_power_law, rn_assumptions, build_equations

# incrementally build common reaction network assumptions
power_law(che::ChemicalHyperEdge{Num}) = src(che) .^ src_stoich(che)
combinatoric_power_law(che::ChemicalHyperEdge{Num}) = power_law(che) ./ factorial.(src_stoich(che))
mass_action(che::ChemicalHyperEdge{Num}; f::Function = src) = rate(che) * prod(f(che))

# assemble reaction network assumptions on a chemical hyperedge
rn_assumptions(che::ChemicalHyperEdge{Num}) = mass_action(che, f = combinatoric_power_law)

# helper function that returns equations describing how the system evolves over time for the given chemical hypergraph
function build_equations(chg::ChemicalHyperGraph{Num}, f::Function; iv::Symbol = :t)
	D    = Differential(iv)
	lhss = [D(x) for x in vertices(chg)]
	rhss = incidence_matrix(chg) * f(chg)
	eqs  = Equation.(lhss, rhss)
end

# overload the ModelingToolkit.ODESystem constructor to work on chemical hypergraphs
function ModelingToolkit.ODESystem(chg::ChemicalHyperGraph, f::Function; p = [], iv = Variable(:t))
	ODESystem(build_equations(chg, f), iv, vertices(chg), p)
end
function ModelingToolkit.ODESystem(chg::ChemicalHyperGraph{Num}, f::Function; p = [], iv = Variable(:t))
	ODESystem(Simulacrum.get_value(build_equations(chg, f)), iv, vertices(chg), p)
end
function ModelingToolkit.ODESystem(chg::ChemicalHyperGraph{T}, f::Function; p = [], iv = Variable(:t)) where {T<:Term}
	ODESystem(convert(ChemicalHyperGraph{Num}, chg), f, p = p, iv = iv)
end

end # module
