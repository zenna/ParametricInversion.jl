export choose

"Axes refers to a subset of the axes (aka dimension, column, attributes) of relation"
const Axes = Tuple
const X = Axes{1,}
const Y = Axes{2,}
const Z = Axes{3,}
const XY = Axes{1,2}
const XZ = Axes{2,3}
const YZ = Axes{2,3}
const XYZ = Axes{1,2,3}

"Indicates we have concrete values for some subset of the relation"
struct Concrete{T<:Axes, V<:Tuple}
  vals::V
end

Concrete{T}(v::V) where {T,V} = Concrete{T, V}(v)

const cX = Concrete{X}
const cY = Concrete{Y}
const cZ = Concrete{Z}
const cXY = Concrete{XY}
const cYZ = Concrete{YZ}
const cXYZ = Concrete{XYZ}

"""
`choose(f, types, target, data`)``

Parametrically choose a value for variables in relation defiend by `f`,
given information about others.

# Arguments
`f(::types...)` - method to choose
`target` - which axis we wish to choose onto
`data`   - data we have on the relation
`θ`      - Parameters to choose
"""
function choose end

const Int2 = Type{Tuple{Int, Int}}
const Floats2 = Type{Tuple{Float64, Float64}}

# Addition / subtraction relation: x + y = z
choose(::typeof(+), t::Int2, ::X, (y, z)::cYZ, θ) = (y - z,)
choose(::typeof(+), t::Int2, ::Type{Z}, xy::cXY, θ) = (xy.vals[1] + xy.vals[2],)
choose(::typeof(+), t::Int2, ::XY, (z)::cZ, θ) = (z - θ, θ)

# Substraction is simply a reoirentation of addition
choose(::typeof(-), t::Int2, ::XZ, (z)::Z, θ) = (z - θ, θ)

