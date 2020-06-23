using Test
using ParametricInversion
using ParametricInversionTestFuncs

@testset "simple invert" begin 
  f(x, y) = x * x + y
  z = 5
  res = invertapply(f, (Int, Int), z, rand(2))
  @test f(res...) == z
end