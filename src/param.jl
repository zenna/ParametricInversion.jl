# Shortcuts for now
unit(φ) = rand()
bools(φ) = unit(φ) > 0.5
bound(φ, a, b) = unit(φ) * b - a + a
reals(φ) = unit(φ) * 1000.0
naturals(φ) = rand(Int64)
const ℝ = reals
const 𝔹 = bools
