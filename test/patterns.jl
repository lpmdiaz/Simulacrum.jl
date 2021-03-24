using Simulacrum

# all to all
n = rand(collect(1:1000))
@test length(indices(AllToAll(n))) == n * (n-1) # n-1 hyperedges (excluding loops)
@test_throws ErrorException AllToAll(1)
@test_throws ErrorException AllToAll(-1)

# cycle
n = rand((1:1000))
@test length(indices(Cycle(n))) == n
@test_throws ErrorException Cycle(0)
@test isa(Cycle(4), AbstractPattern)
@test indices(Cycle(1)) == [(1,1)] # a cycle of length 1 is a loop

# path
n = rand((1:1000))
@test length(indices(Path(n))) == n-1
@test_throws ErrorException Path(0)
