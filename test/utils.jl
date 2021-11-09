using Simulacrum
using Symbolics
import SymbolicUtils: Term, Sym

@test Simulacrum.get_lowest_subtype(Term, Term{Real, Nothing}) == Term{Real, Nothing}
@test Simulacrum.get_lowest_subtype(Sym{Real, Nothing}, Sym) == Sym{Real, Nothing}
@test Simulacrum.get_lowest_subtype(Sym{Real, Nothing}, Sym, Sym{Real}) == Sym{Real, Nothing}

@variables t x(t) y
D = Differential(t)
z = t + t^2
diff = D(z)
eq = Equation(diff, x)

# code below is only useful if this is true
# @test typeof(x) == typeof(diff) == typeof(eq.lhs) == typeof(eq.rhs) == Num
# update: Equation types now come unwrapped out of the box; still keeping these
# in case that changes again in the future

# testing unwrapping of Num via get_value
conv_eq = Simulacrum.get_value(eq)
@test eq == conv_eq
@test typeof(conv_eq.lhs) <: Term{Real} && typeof(conv_eq.rhs) <: Term{Real}
eq = Equation(diff, y)
conv_eq = Simulacrum.get_value(eq)
@test typeof(conv_eq.rhs) <: Sym{Real}

@test Simulacrum.get_sym_name(Symbolics.variable(:x, T = Symbolics.FnType)(t)) == :x # Term
@test Simulacrum.get_sym_name(Symbolics.variable(:x)) == :x # Sym
@test Simulacrum.get_sym_name(Num(Symbolics.variable(:x))) == :x # Num

# make_var (& gen_var)
@variables t
make_var(:test1)
make_var(:test2, 1)
make_var(:test3, t)
make_var(:test4, 1, t)
@test_throws ErrorException make_var(:test5, make_var(:somevar, t))
@test_throws MethodError make_var(:test6, t, t)
x = make_var(:x)
@test x === make_var(:x)
y = make_var(:y, t)
@test isequal(y, make_var(:y, t))

# subscript_var: Term, Sym, and Num types
a = Symbolics.variable(:x, T = Symbolics.FnType)(t)
b = Symbolics.variable(:t)
c = (@variables x(t))[1]
typeof(a) == Term{Real, Nothing}
typeof(b) == Sym{Real, Nothing}
typeof(c) == Num
@test typeof(Simulacrum.subscript_var(a, 1)) == typeof(a)
@test typeof(Simulacrum.subscript_var(b, 1)) == typeof(b)
@test typeof(Simulacrum.subscript_var(c, 1)) == typeof(c)

# subscript_var and subscript_vars
a = Simulacrum.subscript_vars([Symbolics.variable(:x)], 1)[1]
b = Simulacrum.subscript_var(Symbolics.variable(:x), 1)
@test isequal(a, b)

# subscript_var: Num type
@variables x(t) y
@test typeof(Simulacrum.subscript_var(x, 1)) == typeof(x) == Num
@test typeof(Simulacrum.get_value(Simulacrum.subscript_var(x, 1))) == typeof(Simulacrum.get_value(x))
@test typeof(Simulacrum.subscript_var(y, 1)) == typeof(y) == Num

# wrapping Symbolic variables into Num type
@variables t X(t) Y(t)
r = Reaction(2, [X], [Y])
che = convert(ChemicalHyperEdge, r)
@test eltype(convert(ChemicalHyperEdge{Num}, che)) == Num
chx = ChemicalHyperGraph(che)
@test eltype(convert(ChemicalHyperGraph{Num}, chx)) == Num

# converting ordinary edge indices to hyperedge indices for patterns
n = rand((1:1000))
idx = indices(AllToAll(n))
@test length(Simulacrum.edge_idx_to_hyperedge_idx(idx)) == n
idx = indices(Cycle(n))
@test length(Simulacrum.edge_idx_to_hyperedge_idx(idx)) == length(idx)
idx = indices(Path(n))
@test length(Simulacrum.edge_idx_to_hyperedge_idx(idx)) == length(idx)
