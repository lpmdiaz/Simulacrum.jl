module Simulacrum

using HyperGraphs, Symbolics
import SymbolicUtils: Term, Sym, Symbolic
using SimpleTraits
using ModelingToolkit

const SymTypes = Union{Num, Symbolic}
export SymTypes

include("patterns.jl")
include("bridges/modelingtoolkit.jl")
include("connections.jl")
include("operations.jl")
include("reactions.jl")
include("utils.jl")

export

# bridges: modelingtoolkit
mtk_reactions,

# connections
connect, connect!, couple,

# operations
clone,

# patterns
AbstractPattern, indices,
AllToAll, Cycle, Path,

# reactions
isunimolecular, ismultimolecular

end # module
