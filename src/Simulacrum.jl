module Simulacrum

using HyperGraphs
using Symbolics
import SymbolicUtils: Term, Sym, Symbolic

const SymTypes = Union{Num, Symbolic}
export SymTypes

include("reactions.jl")
include("utils.jl")

export

# reactions
isunimolecular, ismultimolecular

end # module
