using Test

const tests = [
    "bridges/modelingtoolkit",
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
