# extending Base.:(==) to allow equality check on symbolic variables (here dispatched on Symbolics Num type)
# Symbolics does extend Base.:(==) but calling `x in [x]` and `x == x` where x is of type Num fails
Base.:(==)(x::Num, y::Num) = x === y

# returns the most specialised type
get_lowest_subtype(t1::Type, t2::Type) = t1 <: t2 ? t1 : t2
get_lowest_subtype(t1::Type, t2::Type, tn...) = get_lowest_subtype(get_lowest_subtype(t1, t2), tn...)

# helper function to unwrap Num types
get_value(n::Num) = Symbolics.value(n)
get_value(eq::Equation) = Equation(get_value(eq.lhs), get_value(eq.rhs))
get_value(eqs::Vector{Equation}) = get_value.(eqs)

# helper that returns the name of a symbolic variable, for a few different types
get_sym_name(s::Term) = s.f.name
get_sym_name(s::Sym) = s.name
get_sym_name(s::Num) = get_sym_name(get_value(s))

# helper function that returns the symbolic variable given as input with the given subscript
function subscript_var(var::Symbolic, sub::Int; iv = Variable(:t))
	symname = get_sym_name(var)
	if var isa Term
		Variable{Symbolics.FnType{Tuple{Any},Real}}(symname, sub)(iv)
	elseif var isa Sym
		Variable(symname, sub)
	end
end
subscript_var(v::Num, sub; iv = Variable(:t)) = Num(subscript_var(get_value(v), sub, iv = iv))
subscript_vars(vars::Vector{T}, sub; iv = Variable(:t)) where {T<:SymTypes} = [subscript_var(var, sub, iv = iv) for var in vars]
