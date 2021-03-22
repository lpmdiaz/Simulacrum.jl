using Simulacrum
using Symbolics

@variables x
@test x == x
@test x in [x]
