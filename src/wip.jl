module Wip
using Simulacrum
using HyperGraphs, Symbolics, ModelingToolkit
using LinearAlgebra: diagm
import SymbolicUtils: Term, Sym

export mass_action, power_law, combinatoric_power_law, rn_assumptions, make_equations, clone_map,
AbstractModel, AbstractBioModel, TelegraphModel, BirthDeathModel, hypergraph, make_Langevin_noise

# incrementally build common reaction network assumptions on chemical hyperedges
power_law(che::ChemicalHyperEdge{Num}) = src(che) .^ src_stoich(che)
parse_stoich(s) = s <= 20 ? s : big(s) # factorial for numbers > 20 needs big
combinatoric_power_law(che::ChemicalHyperEdge{Num}) = power_law(che) ./ factorial.(parse_stoich.(src_stoich(che)))
mass_action(che::ChemicalHyperEdge{Num}; f::Function = src) = rate(che) * prod(f(che))

# assemble reaction network assumptions on a chemical hyperedge
rn_assumptions(che::ChemicalHyperEdge{Num}) = mass_action(che, f = combinatoric_power_law)
rn_assumptions(chx::ChemicalHyperGraph{Num}) = rn_assumptions.(hyperedges(chx))

# helper function that returns equations describing how the system evolves over time for the given chemical hypergraph
function make_equations(x::ChemicalHyperGraph{Num}, f::Function; iv = make_var(:t))
    D    = Differential(iv)
    lhss = [D(v) for v in vertices(x)]
    rhss = incidence_matrix(x) * f(x)
    eqs  = Equation.(lhss, rhss)
end

# overload the ModelingToolkit.ODESystem constructor to work on chemical hypergraphs
function ModelingToolkit.ODESystem(chx::ChemicalHyperGraph, f::Function; iv = make_var(:t), states = vertices(chx), ps = [])
    ODESystem(make_equations(chx, f), iv, states, ps)
end
function ModelingToolkit.ODESystem(chx::ChemicalHyperGraph{Num}, f::Function; iv = make_var(:t), states = vertices(chx), ps = [])
    ODESystem(Simulacrum.get_value(make_equations(chx, f)), iv, states, ps)
end
function ModelingToolkit.ODESystem(chx::ChemicalHyperGraph{T}, f::Function; iv = make_var(:t), ps = []) where {T<:Term}
    ODESystem(convert(ChemicalHyperGraph{Num}, chx), f, iv = iv, ps = ps)
end

# automatically convert equations in matrix form to vector (convenience)
ModelingToolkit.ODESystem(eqs::Matrix{Equation}; iv = make_var(:t), states = get_state_variables(vec(eqs)), ps = get_parameters(vec(eqs))) = ODESystem(vec(eqs), iv, states, ps)

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
function clone_map(in_map::Vector{Pair{T, U}}, x::V) where {T, U, V<:AbstractHyperGraph}
    clone_map(in_map, vertices(x))
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
const ChE = ChemicalHyperEdge
const ChX = ChemicalHyperGraph
abstract type AbstractModel end
abstract type AbstractBioModel <: AbstractModel end
abstract type AbstractPhysModel <: AbstractModel end
hypergraph(m::T) where {T<:AbstractModel} = m.X
make_equations(m::T, f::Function) where {T<:AbstractModel} = make_equations(hypergraph(m), f)
"""
    TelegraphModel

Telegraph model of mRNA production.

active and inactive variables represent time spent in either state; this means that the transition representing transcription is abstract in nature: when the promoter is active, mRNA is transcribed (but not from the active state variable, and so it must appear on either side of the transition).
"""
struct TelegraphModel <: AbstractBioModel
    name::Symbol
    X::AbstractHyperGraph
    TelegraphModel(; name = :Telegraph) = new(name, make_telegraph_x())
end
function make_telegraph_x()
    @variables t inactive(t) active(t) mRNA(t) λ μ k δ
    es = [  ChE([inactive], [active], λ),     # promoter: inactive to active
            ChE([active], [inactive], μ),     # promoter: active to inactive
            ChE([active], [mRNA, active], k), # transcription
            ChE([mRNA], Num[], δ)]            # degradation: mRNA to nothing
    ChX(es)
end
"""
    BirthDeathModel

"""
struct BirthDeathModel <: AbstractBioModel
    name::Symbol
    X::AbstractHyperGraph
    function BirthDeathModel(; name = :BirthDeathModel, var::Symbol = :X)
        @variables t λ μ
        x = Num(Symbolics.variable(var, T = Symbolics.FnType)(t))
        es = [  ChE(Num[], [x], λ),
                ChE([x], Num[], μ)]
        new(name, ChX(es))
    end
end
"""
    LorenzSystemModel

Model of the Lorenz system, known for its chaotic solutions.
"""
struct LorenzSystemModel <: AbstractPhysModel
    name::Symbol
    X::AbstractHyperGraph
    function LorenzSystemModel(; name = :LorenzSystemModel)
        @variables t x(t) y(t) z(t) β ρ σ
        es = [  # dissipation
                ChE([x], Num[], σ),
                ChE([y], Num[], 1),
                ChE([z], Num[], β),

                # one-way interactions
                ChE([x], [x, y], ρ),
                ChE([y], [y, x], σ),

                # two-way interaction
                ChE([x, y], [x, y, z], 1),

                # three-way interaction
                ChE([x, y, z], [x, z], 1/y)]
        new(name, ChX(es))
    end
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
function make_Langevin_noise(x::T, propensities_f::Function; complex = false) where {T<:AbstractHyperGraph}
    !(eltype(x) <: SymTypes) && error("expected a symbolic hypergraph, got $eltype(x)")
    incidence_matrix(x) * diagm(0 => sqrt.((complex ? identity : abs).(propensities_f(x))))
end
function make_Langevin_noise(m::T, propensities_f::Function; complex = false) where {T<:AbstractModel}
    make_Langevin_noise(hypergraph(m), propensities_f, complex = complex)
end

# more methods for get_value
Simulacrum.get_value(ns::Vector{Num}) = Simulacrum.get_value.(ns)
Simulacrum.get_value(ns::Matrix{Num}) = reshape(Simulacrum.get_value(vec(ns)), size(ns))

end # module
