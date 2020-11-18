using Test
using ParametricInversion

function test(x, y, z)
  # Test 
  @test choose(+, Tuple{Int, Int}, Z, cXY((x, 2)), nothing) == x + y
  @test sum(choose(+, Tuple{Int, Int}, XY, cZ((z)), nothing)) == z
end

@testset begin "choose"
  test(3,4,5)
end