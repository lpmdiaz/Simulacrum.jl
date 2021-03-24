abstract type AbstractPattern end

indices(p::AbstractPattern) = p.idx

struct AllToAll <: AbstractPattern
	n::Int								# number of vertices
	idx::Vector{Tuple{Int, Int}}		# edges indices
	function AllToAll(n)
		n > 1 ? new(n, vcat([[(i, j) for j in filter(pos -> pos != i, collect(1:n))] for i in collect(1:n)]...)) : error("incorrect length: $n")
	end
end

struct Cycle <: AbstractPattern
	n::Int								# cycle length
	idx::Vector{Tuple{Int, Int}}		# edges indices
	function Cycle(n)
		n >= 1 ? new(n, [(i, (i%n)+1) for i in 1:n]) : error("cannot make a cycle of length $n")
	end
end

struct Path <: AbstractPattern
	n::Int
	idx::Vector{Tuple{Int, Int}}
	function Path(n)
		n > 0 ? new(n, [(i, i+1) for i in collect(1:n-1)]) : error("incorrect length: $n (must be positive)")
	end
end
