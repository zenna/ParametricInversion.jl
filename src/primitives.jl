invert(::typeof(+), y, φ) = (v = ℝ(φ); (y - v, v))
invert(::typeof(-), y, φ) = (v = ℝ(φ); (y + v, v))
function invert(::typeof(*), y, φ)
  b = 𝔹(φ[2])
  v = ℝ(φ[1])
  b ? (y/v, v) : (v, y/v)
end
invert(::typeof(/), y, φ) = (y*ℝ(φ), ℝ(φ))