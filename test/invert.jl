using Test
using ParametricInversion
using ParametricInversionTestUtils

@testset "simple invert" begin 
  f(x, y, z) = x * y + z
  out = 5
  res = invertapply(f, (Int, Int, Int), out, rand(2))
  @test f(res...) == out
end

@testset "multiple variable use" begin
  function g(x, y)
    a = x + y
    b = a + a
    c = a * a
    d = c + b
    e = y * a
    f = e + d
    return f
  end
  ParametricInversion.invertapplytransform(typeof(g), Tuple{Int, Int})
  invertapply(g, (Int, Int), 3, rand(10))
end


# @testset "Unusued argument" begin
#   function g(x, y, z)
#     a = x + y
#     b = a + a
#     c = a * a
#     d = c + b
#     e = y * a
#     f = e + d
#     return f
#   end
#   ParametricInversion.invertapplytransform(typeof(g), Tuple{Int, Int, Int})
#   invertapplytransform(f, (Int, Int, Int), 3, rand(100))
# end