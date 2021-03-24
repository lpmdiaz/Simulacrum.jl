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
@test typeof(x) == typeof(diff) == typeof(eq.lhs) == typeof(eq.rhs) == Num

# testing unwrapping of Num via get_value
conv_eq = Simulacrum.get_value(eq)
@test eq == conv_eq
@test typeof(conv_eq.lhs) == typeof(conv_eq.rhs) == Term{Real, Nothing}
eq = Equation(diff, y)
conv_eq = Simulacrum.get_value(eq)
@test typeof(conv_eq.rhs) == Sym{Real, Nothing}

@test Simulacrum.get_sym_name(Variable{Symbolics.FnType}(:x)(t)) == :x # Term
@test Simulacrum.get_sym_name(Variable(:x)) == :x # Sym
@test Simulacrum.get_sym_name(Num(Variable(:x))) == :x # Num

# subscript_var: Term, Sym, and Num types
a = Variable{Symbolics.FnType{Tuple{Any},Real}}(:x)(t)
b = Variable(:x)
c = (@variables x(t))[1]
typeof(a) == Term{Real, Nothing}
typeof(b) == Sym{Real, Nothing}
typeof(c) == Num
@test typeof(Simulacrum.subscript_var(a, 1)) == typeof(a)
@test typeof(Simulacrum.subscript_var(b, 1)) == typeof(b)
@test typeof(Simulacrum.subscript_var(c, 1)) == typeof(c)

# subscript_var and subscript_vars
a = Simulacrum.subscript_vars([Variable(:x)], 1)[1]
b = Simulacrum.subscript_var(Variable(:x), 1)
@test isequal(a, b)

# subscript_var: Num type
@variables x(t) y
@test typeof(Simulacrum.subscript_var(x, 1)) == typeof(x) == Num
@test typeof(Simulacrum.get_value(Simulacrum.subscript_var(x, 1))) == typeof(Simulacrum.get_value(x))
@test typeof(Simulacrum.subscript_var(y, 1)) == typeof(y) == Num
