export choose

"Axes refers to a subset of the axes (aka dimension, column, attributes) of relation"
const Axes = Tuple

const T = Axes{1,}
const Z = Axes{2,}
const TZ = Axes{1,2}
const ZA = Axes{2,3}
const ZB = Axes{2,4}
const ZC = Axes{2,5}
const A = Axes{3}
const B = Axes{4}
const C = Axes{5}
const AB = Axes{3, 4}
const BC = Axes{4, 5}
const ABC = Axes{3, 4, 5}

inputaxes(t::Tuple{T}) where T <: Tuple = Axes{2:2+length(T)...}

"Indicates we have concrete values for some subset of the relation"
struct Concrete{T<:Axes, V<:Tuple}
  vals::V
end

Concrete{T}(v::V) where {T,V} = Concrete{T, V}(v)

const cA = Concrete{A}
const cB = Concrete{B}
const cC = Concrete{C}
const cAB = Concrete{AB}
const cBC = Concrete{BC}
const cABC = Concrete{ABC}

"""
`choose(θ, loc, f, types, target, known)`

Parametrically choose a value for variables in relation defined by method
`f(::types..)`, given information about other values in relation.

# Arguments
- `f(::types...)` - method to choose from
- `loc`     - Location
- `target` - which axis we wish to choose onto
- `given`  - what is given/known about values of the relation (e.g. value of input)
- `θ`      - Parameter values which determine which element to choose
"""
function choose end

const Int2 = Type{Tuple{Int, Int}}
const Floats2 = Type{Tuple{Float64, Float64}}
# const RealsT{T} = Type{Tuple{ where T<:

# Addition / subtraction relation: x + y = z
# choose(::typeof(+), t::Int2, ::X, (y, z)::cBC, θ) = (y - z,)
# choose(::typeof(+), t::Int2, ::Type{Z}, xy::cAB, θ) = (xy.vals[1] + xy.vals[2],)
# choose(::typeof(+), t::Int2, ::XY, (z)::cB, θ) = (z - θ, θ)

# # Substraction is simply a reoirentation of addition
# choose(::typeof(-), t::Int2, ::XZ, (z)::Z, θ) = (z - θ, θ)

# +, - relation
choose(θ, ::typeof(+), ::Type{NTuple{2, <:Real}}, ::Type{A}, ::Type{ZB}, z, b) = (z - b,)
choose(θ, ::typeof(+), ::Type{<:NTuple{2, <:Real}}, ::Type{AB}, ::Type{Z}, z) = 
  let θ_ = ℝ(θ) ; (z - θ_, θ_) end


choose(θ, ::typeof(+), ::Type{Tuple{Int, Int}}, ::Type{AB}, ::Type{Z}, z) = 
  let θ_ = ℝ(θ) ; (z - θ_, θ_) end

# *, / relation
choose(θ, ::typeof(*), ::Floats2, ::Type{B}, ::Type{ZA}, z, a) = 
  (z / a,)

function choose(θ, ::typeof(*), ::Floats2, ::Type{AB}, ::Type{Z}, z)
  b = 𝔹(θ)
  v = ℝ(θ)
  b ? (z/v, v) : (v, z/v)
end

choose(θ, ::typeof(/), ::Floats2, ::Type{AB}, ::Type{Z}, z) =
  let r = ℝ(θ)
    (z * r, r)
  end

choose(θ, loc::Loc, args...) = choose(project(θ, loc), args...)