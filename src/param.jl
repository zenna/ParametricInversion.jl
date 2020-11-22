# Shortcuts for now
export reals, bools, integers, unit

bools(θ) = unit(θ) > 0.5
bound(θ, a, b, c) = unit(θ, T) * b - a + a
reals(θ, T = Float64) = (unit(θ, T) - 0.5) * 100.0
integers(θ) = rand(Int64)

const ℝ = reals
const 𝔹 = bools
const ℤ = integers

function choose(branches, θ)
  return 1
end