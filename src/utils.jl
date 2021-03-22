# extending Base.:(==) to allow equality check on symbolic variables (here dispatched on Symbolics Num type)
# Symbolics does extend Base.:(==) but calling `x in [x]` and `x == x` where x is of type Num fails
Base.:(==)(x::Num, y::Num) = x === y
