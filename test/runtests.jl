using Test

const tests = [
    "reactions",
    "utils"
]

for test in tests
    @testset "$test" begin include("$test.jl") end
end
