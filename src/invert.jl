export invertapply, invertir

"""
`invertapply(f, t::Type{<:Tuple}, z, θ)`

Parametric inverse application of method `f(::t...)` to `args` with parameters `θ`
# Inputs:
`f` - function to invert
`t` - Tuple of types which determines method of `f` to invert
`z` - Input to inverse method
`θ` - Parameter values

# Returns
`(a, b, c, ...)` - tuple of values 

```
f(x, y, z) = x * y + z
x, y, z = invertapply(f, Tuple{Float64, Float64, Float64}, 2.3, rand(3))
@assert f(x, y, z) == 2.3
```
"""
invertapply(f, t::Type{T}, z, θ) where {T<:Tuple} = 
  choose(f, t, places_from_argtypes(T), ZΘ, z, θ)

"""
`invertir(f, t::Type{T})`

Produce inverse ast for method `f(::T)`
"""
invertir(f, t::Type{T}) where {T<:Tuple} = 
  reorientir(typeof(f), t, ZΘ, :inputsfixme)

@post length(T.parameters) == length(ret) "Output should be the right length"
@post all(map(isa, ret, T.parameters)) "Each element of ret is correct type"
@post Base.invoke(f, t, ret...) == z "Is valid inverse element"

function invertapply(f, types::NTuple{N, DataType}, arg, φ) where N
  invertapply(f, Base.to_tuple_type(types), Z(), arg, φ)
end

invertir(f, t::Type{T}) where {T} = reorientir(f, t, places_from_argtypes(T), ZΘ()) 