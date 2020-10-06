invertapply(::typeof(+), t::Type{Tuple{Float64, Float64}}, y, φ) = (v = ℝ(φ); (y - v, v))
# invertapply(::typeof(+), t::Tuple{T}, y, φ) where T = (v = ℝ(φ); (y - v, v))
# invertapply(::typeof(+), t::Type{Int64}, y, φ) = (v = naturals(φ); (y-v, v))

invertapply(::typeof(-), types::Type{T}, y, φ) where T = (v = ℝ(φ); (y + v, v))

function invertapply(::typeof(*), t::Type{Tuple{Float64, Float64}}, y, φ)
  b = 𝔹(φ[2])
  v = ℝ(φ[1])
  b ? (y/v, v) : (v, y/v)
end

function invertapply(::typeof(*), t::Type{Tuple{Float64, PIConstant{T}}}, constants, y, φ) where T
  c = constants[1].value
  (y/c, c)
end

# function invertapply(::typeof(*), t::Type{T}, y, φ) where T
#   b = 𝔹(φ[2])
#   v = naturals(φ[1])
#   b ? (y/v, v) : (v, y/v)
# end
invertapply(::typeof(/), types::Type{T}, y, φ) where T = (y*ℝ(φ), ℝ(φ))

### TODO:
# handle multiple arguments like :+(%2, %3, %4, %5) (all with potentially different types)