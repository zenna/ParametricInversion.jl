using Test
using ParametricInversion
using ParametricInversionTestUtils

@testset "simple invert" begin 
  f(x, y, z) = x * y + z
  out = 5
  res = invertapply(f, (Int, Int, Int), out, rand(2))
  @test f(res...) == out
end