using Test

const tests = [
    "bridges/modelingtoolkit",
    "operations",
    "patterns",
    "reactions",
    "utils"
]

for test in tests
    @testset "$(replace(test, "/" => ": "))" begin include("$test.jl") end
end
