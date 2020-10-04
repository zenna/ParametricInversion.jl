using Arithmetic
using Test

# 4 
@test evaluate(Constant(4)) == 4

# 1 * 3
@test evaluate(BinaryOp(Constant(1), MUL, Constant(3))) == 3
# 2 + 4 / 4
@test evaluate(BinaryOp(Constant(2), ADD, BinaryOp(Constant(4), DIV, Constant(4)))) == 3
