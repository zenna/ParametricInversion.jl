const Float64_2 = Type{Tuple{Float64, Float64}}

# +, - relation
choose(θ, ::typeof(+), ::Type{NTuple{2, <:Real}}, ::Type{A}, ::Type{ZB}, z, b) = (z - b,)
choose(θ, ::typeof(+), ::Type{<:NTuple{2, T}}, ::Type{AB}, ::Type{Z}, z) where {T <:Real} = 
  let θ_ = ℝ(θ, T) ; (z - θ_, θ_) end
choose(θ, ::typeof(+), ::Type{Tuple{Int, Int}}, ::Type{AB}, ::Type{Z}, z) = 
  let θ_ = integers(θ) ; (z - θ_, θ_) end

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

## == relation
function choose(θ, ::typeof(==), ::Type{Tuple{Int64, Int64}}, ::Type{A}, ::Type{ZB}, z::Bool, b::Int64)
  if z
    (b,)
  else
    error("unhandled")
  end
end

## Logical
## =======

# &
function choose(θ, ::typeof(&), ::Type{Tuple{Bool, Bool}}, ::Type{AB}, ::Type{Z}, z::Bool)
  if z
    (true, true)
  else
    finitechoice(θ, ((true, false), (false, false), (false, true)))
  end
end

## String
## ======
function choose(θ, ::typeof(count), ::Type{Tuple{String, String}}, ::Type{B}, ::Type{ZA}, z::Int64, a::String)
  # Produce a string with `z` copies of `a`
  # This is too free of a choice - we need some more information from somewhere.
end





### TODO:
# Handle multiple arguments like :+(%2, %3, %4, %5) (all with potentially different types)
# Handle inverse integer multiplication and division: factoring problems
# Define more primitives as needed
