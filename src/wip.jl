module Wip
using Simulacrum
using HyperGraphs, Symbolics, ModelingToolkit
using LinearAlgebra: diagm
import SymbolicUtils: Term, Sym

export mass_action, power_law, combinatoric_power_law, rn_assumptions, make_equations, clone_map,
AbstractModel, TelegraphModel, hypergraph, make_Langevin_noise

# incrementally build common reaction network assumptions on chemical hyperedges
power_law(che::ChemicalHyperEdge{Num}) = src(che) .^ src_stoich(che)
combinatoric_power_law(che::ChemicalHyperEdge{Num}) = power_law(che) ./ factorial.(src_stoich(che))
mass_action(che::ChemicalHyperEdge{Num}; f::Function = src) = rate(che) * prod(f(che))

# assemble reaction network assumptions on a chemical hyperedge
rn_assumptions(che::ChemicalHyperEdge{Num}) = mass_action(che, f = combinatoric_power_law)
rn_assumptions(chg::ChemicalHyperGraph{Num}) = rn_assumptions.(hyperedges(chg))

# helper function that returns equations describing how the system evolves over time for the given chemical hypergraph
function make_equations(chg::ChemicalHyperGraph{Num}, f::Function; iv::Symbol = :t)
    D    = Differential(iv)
    lhss = [D(x) for x in vertices(chg)]
    rhss = incidence_matrix(chg) * f(chg)
    eqs  = Equation.(lhss, rhss)
end

# overload the ModelingToolkit.ODESystem constructor to work on chemical hypergraphs
function ModelingToolkit.ODESystem(chg::ChemicalHyperGraph, f::Function; iv = Variable(:t), states = vertices(chg), ps = [])
    ODESystem(make_equations(chg, f), iv, states, ps)
end
function ModelingToolkit.ODESystem(chg::ChemicalHyperGraph{Num}, f::Function; iv = Variable(:t), states = vertices(chg), ps = [])
    ODESystem(Simulacrum.get_value(make_equations(chg, f)), iv, states, ps)
end
function ModelingToolkit.ODESystem(chg::ChemicalHyperGraph{T}, f::Function; iv = Variable(:t), ps = []) where {T<:Term}
    ODESystem(convert(ChemicalHyperGraph{Num}, chg), f, iv = iv, ps = ps)
end

# automatically convert equations in matrix form to vector (convenience)
ModelingToolkit.ODESystem(eqs::Matrix{Equation}; iv = Variable(:t), states = get_state_variables(vec(eqs)), ps = get_parameters(vec(eqs))) = ODESystem(vec(eqs), iv, states, ps)

# helper function that takes a hypergraph that has been made by cloning a base model n times and returns a map to be used with ModelingToolkit
function clone_map(in_map::Vector{Pair{T, U}}, clones::Vector) where {T, U}
    out_map = Vector{eltype(in_map)}()
    for i in 1:length(in_map):length(clones)
        for j in 1:length(in_map)
            push!(out_map, (clones[i + j - 1] => in_map[j].second))
        end
    end
    out_map
end
function clone_map(in_map::Vector{Pair{T, U}}, hg::V) where {T, U, V<:AbstractHyperGraph}
    clone_map(in_map, vertices(hg))
end

# helper function that makes maps to be used with e.g. ModelingToolkit
function make_map(firsts::Vector, seconds::Vector)
    @assert length(firsts) == length(seconds)
    [(firsts[i] => seconds[i]) for i in 1:length(firsts)]
end

# dispatch susbstitute on vectors of equations (convenience)
Symbolics.substitute(eqs::Vector{Equation}, d::Dict) = [substitute(eq, d) for eq in eqs]
Symbolics.substitute(nums::Vector{Num}, d::Dict) = [substitute(num, d) for num in nums]

# helper that returns the left-hand sides of equations wrapped in Num type
get_lhs_var(eq::Equation) = Num(Symbolics.get_variables(eq.lhs)[1])
get_lhss_vars(eqs::Vector{Equation}) = get_lhs_var.(eqs)

# helper that returns equations state variables
function get_state_variables(eq::Equation)
    all_vars = Num.(union(Symbolics.get_variables(eq.rhs)))
    filter(x -> Simulacrum.get_value(x) isa Term, all_vars)
end
get_state_variables(eqs::Vector{Equation}) = union(vcat(get_state_variables.(eqs)...))

# helper that returns equations parameters
function get_parameters(eq::Equation)
    all_vars = Num.(union(Symbolics.get_variables(eq.rhs)))
    filter(x -> Simulacrum.get_value(x) isa Sym, all_vars)
end
get_parameters(eqs::Vector{Equation}) = union(vcat(get_parameters.(eqs)...))

# prototype of models.jl
const CHE = ChemicalHyperEdge
const CHG = ChemicalHyperGraph
abstract type AbstractModel end
abstract type AbstractBioModel <: AbstractModel end
hypergraph(m::T) where {T<:AbstractModel} = m.HG
make_equations(m::T, f::Function) where {T<:AbstractModel} = make_equations(hypergraph(m), f)
"""
    TelegraphModel

Telegraph model of mRNA production.

active and inactive variables represent time spent in either state; this means that the transition representing transcription is abstract in nature: when the promoter is active, mRNA is transcribed (but not from the active state variable, and so it must appear on either side of the transition).
"""
struct TelegraphModel <: AbstractBioModel
    name::Symbol
    HG::AbstractHyperGraph
    TelegraphModel(; name = :Telegraph) = new(name, make_telegraph_hg())
end
function make_telegraph_hg() # add IsOriented, add optional inputs to give type of hypergraph and hyperedges (e.g. :Chemical)
    @variables t inactive(t) active(t) mRNA(t) λ μ k δ
    hes = [ CHE([inactive], [active], λ),     # promoter: inactive to active
            CHE([active], [inactive], μ),     # promoter: active to inactive
            CHE([active], [mRNA, active], k), # transcription
            CHE([mRNA], Num[], δ)]            # degradation: mRNA to nothing
    CHG(hes)
end

# helper that returns an Expr that can be evaluated to expose variables into the global scope, specifically written for Num types (for now)
expose_sym(sym::Num) = :( $(sym.val.name) = $sym )
expose_term(term::Num) = :( $(term.val.f.name) = $term )
expose(num::Num) = (num.val isa Sym ? expose_sym : expose_term)(num)
expose(nums::Vector{Num}) = expose.(nums)
macro expose(arg) # only works for one symbolic variable at a time...
    expose(eval(arg)) |> esc
end

# returns a matrix of Langevin (intrinsic) noise terms
function make_Langevin_noise(hg::T, propensities_f::Function) where {T<:AbstractHyperGraph}
    !(eltype(hg) <: SymTypes) && error("expected a symbolic hypergraph, got $eltype(hg)")
    incidence_matrix(hg) * diagm(0 => sqrt.(propensities_f(hg)))
end
function make_Langevin_noise(m::T, propensities_f::Function) where {T<:AbstractModel}
    make_Langevin_noise(hypergraph(m), propensities_f)
end

# more methods for get_value
Simulacrum.get_value(ns::Vector{Num}) = Simulacrum.get_value.(ns)
Simulacrum.get_value(ns::Matrix{Num}) = reshape(Simulacrum.get_value(vec(ns)), size(ns))

end # module
