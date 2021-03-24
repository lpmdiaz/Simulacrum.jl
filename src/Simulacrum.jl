module Simulacrum

using HyperGraphs
using Symbolics
import SymbolicUtils: Term, Sym, Symbolic

const SymTypes = Union{Num, Symbolic}
export SymTypes

include("utils.jl")

end # module
