using Test

const tests = [
    "utils"
]

for test in tests
    @testset "$test" begin include("$test.jl") end
end
