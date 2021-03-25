module Simulacrum

using HyperGraphs
using Symbolics
import SymbolicUtils: Term, Sym, Symbolic
using ModelingToolkit

const SymTypes = Union{Num, Symbolic}
export SymTypes

include("bridges/modelingtoolkit.jl")
include("operations.jl")
include("patterns.jl")
include("reactions.jl")
include("utils.jl")

export

# bridges: modelingtoolkit
mtk_reactions,

# operations
clone,

# patterns
AbstractPattern, indices,
AllToAll, Cycle, Path,

# reactions
isunimolecular, ismultimolecular

end # module
