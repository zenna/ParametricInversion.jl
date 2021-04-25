invertapply(::typeof(+), t::Type{Tuple{Float64, Float64}}, y, ϴ) = (v = ℝ(ϴ); (y - v, v))
invertapply(::typeof(+), t::Type{Tuple{Int64, Int64}}, y, ϴ) = (v = ℤ(ϴ); (y - v, v))
invertapply(::typeof(+), t::Type{Tuple{T, T}}, y, ϴ) where T = (v = ℝ(ϴ); (y - v, v))

invertapply(::typeof(-), t::Type{Tuple{Int64, Int64}}, y, ϴ) = (v = ℤ(ϴ); (y + v, v))
invertapply(::typeof(-), t::Type{Tuple{Float64, Float64}}, y, ϴ) = (v = ℝ(ϴ); (y + v, v))
invertapply(::typeof(-), types::Type{Tuple{T, T}}, y, ϴ) where T = (v = ℝ(ϴ); (y + v, v))

function invertapply(::typeof(*), t::Type{Tuple{Float64, Float64}}, y, ϴ)
  b = 𝔹(ϴ[2])
  v = ℝ(ϴ[1])
  b ? (y/v, v) : (v, y/v)
end

function invertapply(::typeof(*), t::Type{Tuple{Float64, PIConstant{T}}}, constants, y, ϴ) where T
  c = constants[1].value
  (y/c, c)
end

function invertapply(::typeof(*), t::Type{Tuple{T, T}}, y, ϴ) where T
  b = 𝔹(ϴ[2])
  v = ℝ(ϴ[1])
  b ? (y/v, v) : (v, y/v)
end
invertapply(::typeof(/), types::Type{Tuple{T, T}}, y, ϴ) where T = (y*ℝ(ϴ), ℝ(ϴ))

### TODO:
# Handle multiple arguments like :+(%2, %3, %4, %5) (all with potentially different types)
# Handle inverse integer multiplication and division: factoring problems
# Define more primitives as needed
