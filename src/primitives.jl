invert(::typeof(+), types::Type{T}, y, φ) where T = (v = ℝ(φ); (y - v, v))
invert(::typeof(-), types::Type{T}, y, φ) where T = (v = ℝ(φ); (y + v, v))
function invert(::typeof(*), types::Type{T}, y, φ) where T
  b = 𝔹(φ[2])
  v = ℝ(φ[1])
  b ? (y/v, v) : (v, y/v)
end
invert(::typeof(/), types::Type{T}, y, φ) where T = (y*ℝ(φ), ℝ(φ))