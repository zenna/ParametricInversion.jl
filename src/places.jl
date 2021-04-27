"Axes refers to a subset of the axes (aka dimension, column, attributes) of relation"
struct Places{T <: Tuple} end
const Place{I} = Places{Tuple{I}}

const Θ = Place{1}
const Z = Place{2}
const A = Place{3}
const B = Place{4}
const C = Place{5}

Base.:*(p1::Type{Places{Tuple{I}}}, p2::Type{Places{Tuple{J}}}) where {I, J} = Places{Tuple{I, J}}
Base.:*(p1::Type{Places{Tuple{I, J}}}, p2::Type{Places{Tuple{K}}}) where {I, J, K} = Places{Tuple{I, J, K}}
Base.:*(p1::Type{Places{Tuple{I}}}, p2::Type{Places{Tuple{J, K}}}) where {I, J, K} = Places{Tuple{I, J, K}}

const DIMSTOSYM = [:θ, :Z, Symbol.(collect('A':'Y'))...]

h(I) = I in 1:length(DIMSTOSYM) ? DIMSTOSYM[I] : I

Base.show(io::IO, ::Type{Places{Tuple{I}}}) where {I} = print(io, "Placdes{$(h(I))}")
Base.show(io::IO, ::Type{Places{Tuple{I, J}}}) where {I, J} = print(io, "Places{$(h(I)), $(h(J))}")
Base.show(io::IO, ::Type{Places{Tuple{I, J, K}}}) where {I, J, K} = print(io, "Places{$(h(I)), $(h(J)), $(h(K))}")
Base.show(io::IO, ::Type{Places{Tuple{I, J, K, L}}}) where {I, J, K, L} = print(io, "Places{$(h(I)), $(h(J)), $(h(K)), $(h(L))}")

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

function places(s::Statement)
  Place(2:2+length(1:s.expr.args))
end




# "Indicates we have concrete values for some subset of the relation"
# struct Concrete{T<:Axes, V<:Tuple}
#   vals::V
# end

# Concrete{T}(v::V) where {T,V} = Concrete{T, V}(v)

# const cA = Concrete{A}
# const cB = Concrete{B}
# const cC = Concrete{C}
# const cAB = Concrete{AB}
# const cBC = Concrete{BC}
# const cABC = Concrete{ABC}

