using Simulacrum, Simulacrum.Wip
using HyperGraphs, Symbolics
using Catalyst

@variables t X(t) Y(t) Z(t)
che1 = ChemicalHyperEdge([X], [Y], 2)
che2 = ChemicalHyperEdge([X, Y], [Z], 2)
che3 = ChemicalHyperEdge(SpeciesSet([X], [3]), SpeciesSet{Num}(), 1)
chx = ChemicalHyperGraph([che1, che2, che3])

# full dynamics on chemical hyperedges, purely from assumptions and topology
ode_rate_law(che::ChemicalHyperEdge{Num}) = rn_assumptions(che)
ode_rate_law(chx::ChemicalHyperGraph{Num}) = ode_rate_law.(hyperedges(chx))

## propensities ##

# mass action
@test isequal(mass_action(che1), 2*X)
@test isequal(mass_action(che2), 2*X*Y)
@test isequal(mass_action(che3), X)

# power law
@test isequal(power_law(che1), [X])
@test isequal(power_law(che2), [X, Y])
@test isequal(power_law(che3), [X^3])

# combinatoric power law
@test isequal(combinatoric_power_law(che1), [X])
@test isequal(combinatoric_power_law(che2), [X, Y])
@test isequal(combinatoric_power_law(che3), [(X^3)/6])

## rate laws ##

# ODE rate law
@test isequal(ode_rate_law(che1), 2*X)
@test isequal(ode_rate_law(che2), 2*X*Y)
@test isequal(ode_rate_law(che3), (X^3)/6)

# full equations
D = Differential(:t)
ref_eqs = [ Equation(D(X), - 2*X - 2*X*Y - (X^3)/2),
            Equation(D(Y), 2*X - 2*X*Y),
            Equation(D(Z), 2*X*Y)]
@test isequal(make_equations(chx, ode_rate_law), ref_eqs)

# zeroth order reactions
@test isequal(ode_rate_law(ChemicalHyperEdge(Num[], [X], 3)), 3)
@test isequal(ode_rate_law(ChemicalHyperEdge([X], Num[], 3)), 3X)

## benchmarking against ModelingToolkit to make sure the equations are correct ##

chx_eqs = Simulacrum.get_value(make_equations(chx, ode_rate_law))
r1 = Reaction(2, [X], [Y])
r2 = Reaction(2, [X, Y], [Z])
r3 = Reaction(1, [X], nothing, [3], nothing)
@named rsys = ReactionSystem([r1, r2, r3], t, [X, Y, Z], [])
sys = convert(ODESystem, rsys)
mtk_eqs = equations(sys)
chx_eqs_rhss = [eq.rhs for eq in chx_eqs]
mtk_eqs_rhss = [eq.rhs for eq in mtk_eqs]
@test isequal(chx_eqs_rhss, mtk_eqs_rhss) # for some reason the left hand sides aren't equal
