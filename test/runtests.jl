using Test

const tests = [
    "bridges/catalyst",
    "connections",
    "operations",
    "patterns",
    "reactions",
    "utils",
    "wip"
]

for test in tests
    @testset "$(replace(test, "/" => ": "))" begin include("$test.jl") end
end
