const Float64_2 = Type{Tuple{Float64, Float64}}

# +, - relation
choose(θ, ::typeof(+), ::Type{NTuple{2, <:Real}}, ::Type{A}, ::Type{ZB}, z, b) = (z - b,)
choose(θ, ::typeof(+), ::Type{<:NTuple{2, <:Real}}, ::Type{AB}, ::Type{Z}, z) = 
  let θ_ = ℝ(θ) ; (z - θ_, θ_) end
choose(θ, ::typeof(+), ::Type{Tuple{Int, Int}}, ::Type{AB}, ::Type{Z}, z) = 
  let θ_ = ℝ(θ) ; (z - θ_, θ_) end


# *, / relation -- z = a * b
choose(θ, ::typeof(*), ::Float64_2, ::Type{B}, ::Type{ZA}, z, a) = 
  (z / a,)

function choose(θ, ::typeof(*), ::Float64_2, ::Type{AB}, ::Type{Z}, z)
  b = 𝔹(θ)
  v = ℝ(θ)
  b ? (z/v, v) : (v, z/v)
end

choose(θ, ::typeof(*), ::Float64_2, ::Type{A}, ::Type{ZB}, z, b) = 
  (a = z / b,)

choose(θ, ::typeof(/), ::Float64_2, ::Type{AB}, ::Type{Z}, z) =
  let r = ℝ(θ)
    (z * r, r)
  end

choose(θ, loc::Loc, args...) = choose(project(θ, loc), args...)
### TODO:
# Handle multiple arguments like :+(%2, %3, %4, %5) (all with potentially different types)
# Handle inverse integer multiplication and division: factoring problems
# Define more primitives as needed
