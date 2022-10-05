# extending Base.in to Symbolics.Num types (useful for HyperGraphs of Num type)
Base.in(x::Num, collection::AbstractVector) = any(isequal(x, y) for y in collection)

# returns the most specialised type
get_lowest_subtype(t1::Type, t2::Type) = t1 <: t2 ? t1 : t2
get_lowest_subtype(t1::Type, t2::Type, tn...) = get_lowest_subtype(get_lowest_subtype(t1, t2), tn...)

# helper function to unwrap Num types
get_value(n::Num) = Symbolics.value(n)
get_value(eq::Equation) = Equation(get_value(eq.lhs), get_value(eq.rhs))
get_value(eqs::Vector{Equation}) = get_value.(eqs)

# temporary addition in order to buffer out changes in Symbolics; allows to fall
# back on a default case while the code is still being updated
get_value(x::T) where {T<:Symbolic} = x

# helper that returns the name of a symbolic variable, for a few different types
get_sym_name(s::Term) = s.f.name
get_sym_name(s::Sym) = s.name
get_sym_name(s::Num) = get_sym_name(get_value(s))

# helpers that abstract away the Symbolics syntax
function _check_symvar(var::Num)
    if isa(get_value(var), Sym)
        true
    else
        vartype = typeof(get_value(var)).name.wrapper
        error("$var of type $vartype; expected SymbolicUtils.Sym")
    end
end
_make_subname(symname::Symbol, idx::Int) = Symbol(symname, join(Symbolics.map_subscripts.(idx)))
genvar(symname::Symbol) = first(@variables $symname)
function genvar(symname::Symbol, idx::Int)
    (name = _make_subname(symname, idx); first(@variables $name))
end
function genvar(symname::Symbol, var::Num)
    _check_symvar(var) && first(@variables $symname($var))
end
function genvar(symname::Symbol, idx::Int, var::Num)
    _check_symvar(var) && (name = _make_subname(symname, idx); first(@variables $name($var)))
end

# helpers acting as a gateway to genvar. this might later check whether the variable already exists or not; if it does, it would then just evaluate it and not generate it again. may be renamed to use_var when that behaviour is implemented
make_var(symname::Symbol, args...) = genvar(symname, args...)
make_vars(symnames::Vector{Symbol}, args...) = [genvar(symname, args...) for symname in symnames]

# helper function that returns the symbolic variable given as input with the given subscript
function subscript_var(var::Symbolic, sub::Int; iv = genvar(:t))
    symname = get_sym_name(var)
    if var isa Term
        genvar(symname, sub, iv)
    elseif var isa Sym
        genvar(symname, sub)
    end
end
subscript_var(v::Num, sub; iv = genvar(:t)) = Num(subscript_var(get_value(v), sub, iv = iv))
subscript_vars(vars::Vector{T}, sub; iv = genvar(:t)) where {T<:SymTypes} = [subscript_var(var, sub, iv = iv) for var in vars]

# wrap SymbolicUtils variables in chemical hyperedges and hypergraphs into Symbolics.Num
# useful when converting ModelingToolkit types to chemical hypergraphs and hyperedges and still use the Simulacrum functions that are defined on Num
function Base.convert(::Type{ChemicalHyperEdge{Num}}, che::ChemicalHyperEdge{T}) where {T<:Symbolic}
    ChemicalHyperEdge(SpeciesSet(Num.(objects(che.src)), src_stoich(che)), SpeciesSet(Num.(objects(che.tgt)), tgt_stoich(che)), weight(che))
end
function Base.convert(::Type{ChemicalHyperGraph{Num}}, chx::ChemicalHyperGraph{T}) where {T<:Symbolic}
    ChemicalHyperGraph{Num}(Num.(vertices(chx)), convert.(ChemicalHyperEdge{Num}, hyperedges(chx)))
end

# convert directed edge indices to oriented hyperedges (one source, several targets from aggregated edges)
function edge_idx_to_hyperedge_idx(idx::Vector{Tuple{Int, Int}})

    # group ordinary edge indices according to their source vertex;
    # edge indices in each group have the same source vertex but different target vertex
    groups = [filter(v -> first(v) == i, idx) for i in 1:maximum(first.(idx))]

    # make hyperedge indices by concatenating all targets within each group
    elist = Vector{Tuple{Vector{Int}, Vector{Int}}}(undef, length(groups))
    @inbounds for (i, group) in enumerate(groups)
        elist[i] = ([first(group[1])], last.(group))
    end
    elist

end
