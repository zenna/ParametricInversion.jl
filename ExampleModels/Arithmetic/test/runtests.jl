using Arithmetic
using Test

# 4 
@testset "Evaluate constant" begin
  @test evaluate(Constant(4)) == 4
end

# 1 * 3
@testset "Simple multiplication" begin
  @test evaluate(BinaryOp(Constant(1), MUL, Constant(3))) == 3
end

# 2 + 4 / 4
@testset "Nested operations" begin
  @test evaluate(BinaryOp(Constant(2), ADD, BinaryOp(Constant(4), DIV, Constant(4)))) == 3
end