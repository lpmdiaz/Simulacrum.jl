module Simulacrum

using HyperGraphs, Symbolics
import SymbolicUtils: Term, Sym, Symbolic
using SimpleTraits
using ModelingToolkit
using Catalyst

const SymTypes = Union{Num, Symbolic}
export SymTypes

include("patterns.jl")
include("bridges/catalyst.jl")
include("connections.jl")
include("operations.jl")
include("reactions.jl")
include("utils.jl")
include("wip.jl")

export

# bridges: catalyst
catalyst_reactions,

# connections
connect, connect!, couple,

# operations
clone,

# patterns
AbstractPattern, indices,
AllToAll, Cycle, Path,

# reactions
isunimolecular, ismultimolecular,
reversible_reaction, @reversible,

# utils
make_var

end # module
