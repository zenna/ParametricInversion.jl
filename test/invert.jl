using Test



const ϵ = 0.000001

@testset "simple invert" begin 
  f(x, y, z) = x * y + z
  out = 5
  res = invertinvoke(f, Tuple{Float64, Float64, Float64}, out, rand(2))
  @test f(res...) ≈ out atol=ϵ
end

@testset "invert with constants" begin
  f(x, y) = x * 2 + y * 3
  out = 100
  res = invertinvoke(f, (Float64, Float64), out, rand(2))
  @test f(res...) ≈ out atol=ϵ
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
  ParametricInversion.invertinvoketransform(typeof(g), Tuple{Float64, Float64})
  invertinvoke(g, (Float64, Float64), 3, rand(10))
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
#   ParametricInversion.invertinvoketransform(typeof(g), Tuple{Int, Int, Int})
#   invertinvoketransform(f, (Int, Int, Int), 3, rand(100))
# end