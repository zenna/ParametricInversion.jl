"Places refers to a subset of the axes (aka dimension, column, attributes) of relation"
struct Places{T <: Tuple} end
const Place{I} = Places{Tuple{I}}

# First input is INPUTOFFSETth place
const INPUTOFFSET = 2

places(ts) = Places{Tuple{ts...}}
inputplaces(ids) = places(INPUTOFFSET .+ ids)
# inputplaces(s::Statement) = inputplaces(1:length(1:s.expr.args))

const Θ = Place{1}
const Z = Place{2}
const A = Place{3}
const B = Place{4}
const C = Place{5}
const D = Place{5}

Base.:*(p1::Type{Places{Tuple{I}}}, p2::Type{Places{Tuple{J}}}) where {I, J} = Places{Tuple{I, J}}
Base.:*(p1::Type{Places{Tuple{I, J}}}, p2::Type{Places{Tuple{K}}}) where {I, J, K} = Places{Tuple{I, J, K}}
Base.:*(p1::Type{Places{Tuple{I}}}, p2::Type{Places{Tuple{J, K}}}) where {I, J, K} = Places{Tuple{I, J, K}}

const DIMSTOSYM = [:Θ, :Z, Symbol.(collect('A':'Y'))...]

h(I) = I in 1:length(DIMSTOSYM) ? DIMSTOSYM[I] : I

Base.show(io::IO, ::Type{Places{Tuple{I}}}) where {I} = print(io, "Places{$(h(I))}")
Base.show(io::IO, ::Type{Places{Tuple{I, J}}}) where {I, J} = print(io, "Places{$(h(I)), $(h(J))}")
Base.show(io::IO, ::Type{Places{Tuple{I, J, K}}}) where {I, J, K} = print(io, "Places{$(h(I)), $(h(J)), $(h(K))}")
Base.show(io::IO, ::Type{Places{Tuple{I, J, K, L}}}) where {I, J, K, L} = print(io, "Places{$(h(I)), $(h(J)), $(h(K)), $(h(L))}")
Base.show(io::IO, ::Type{Places{T}}) where {T<:Tuple} = print(io, "Places{$(join([h(i) for i in 1:length(T.types)], ", "))}")

const ZA = Z * A
const ZB = Z * B
const ZC = Z * C
const AB = A * B
const BC = B * C 
const ABC = A * B * C
const ZΘ = Z * Θ

# Produces places correpsoinding to argument types
places_from_argtypes(t::Type{Tuple{T1}}) where {T1} = A
places_from_argtypes(t::Type{Tuple{T1, T2}}) where {T1, T2} = A * B
places_from_argtypes(t::Type{Tuple{T1, T2, T3}}) where {T1, T2, T3} = A * B * C
places_from_argtypes(t::Type{<:Tuple}) = inputplaces(1:length(t.types))