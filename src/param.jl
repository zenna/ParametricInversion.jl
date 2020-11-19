# Shortcuts for now
unit(φ) = rand()
bools(φ) = unit(φ) > 0.5
bound(φ, a, b) = unit(φ) * b - a + a
reals(φ) = unit(φ) * 1000.0
integers(φ) = rand(Int64)
const ℝ = reals
const 𝔹 = bools
const ℤ = integers


# TODO: use phi to actually choose a branch intelligently
# TODO: add arguments like path through blocks? depends on our value addressing scheme.
function choosebranch(branches, φ)
  return 1
end