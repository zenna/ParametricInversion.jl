using Arithmetic
# Simple Tests
# 4 
println(evaluate(Constant(4)))

# 1 * 3
println(evaluate(BinaryOp(Constant(1), MUL, Constant(3))))
# 2 + 4 / 4
println(evaluate(BinaryOp(Constant(2), ADD, BinaryOp(Constant(4), DIV, Constant(4)))))
