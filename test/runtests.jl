using ParametricInversion
using ParametricInversionTestUtils
using Test
using Random
Random.seed!(0)

@testset "ParametricInversion.jl" begin
  include("invert.jl")
end
