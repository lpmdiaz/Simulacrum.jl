module Simulacrum

using HyperGraphs
using Symbolics
import SymbolicUtils: Term, Sym, Symbolic
using ModelingToolkit

const SymTypes = Union{Num, Symbolic}
export SymTypes

include("bridges/modelingtoolkit.jl")
include("reactions.jl")
include("utils.jl")

export

# reactions
isunimolecular, ismultimolecular

end # module
