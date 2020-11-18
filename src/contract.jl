"`x' = contract(d, x)` implies x ∈ d`"
function contract end

"`codomain(f, t)` -- codomain of method `f(::t...)`"
function codomain end

# zt - fix me
contract(i::Interval, x) = softmax()
contract(::Type{Any}, x) = x

# zt - whatabout closed vs open interval
"Interval [l, u]"
struct Interval{T}
  l::T
  u::T
end
l..u = Interval(l, u)

codomain(::typeof(sin), t) =  -1..1
codomain(::typeof(cos), t) =  -1..1
codomain(::typeof(sqrt), t) = -1..1

# Unless otherwise specified, assume a function is unconstrained
codomain(f, t) = Any

# zt - something a bit odd about using Any for codmain of arbitray function#
# zt - maybe its better to think of it as something else

# zt - we only want to bother contracting if the function is contractable
invertapply(traits::trait(Contract), f, t, y, ϕ) =
  invertapply(f, t, contract(traits, codomain(f, t), y), ϕ)

# move this into 
invertapply(traits, f, t, y, ϕ) = 
  invertapply(t, f, t, y, ϕ)

# Handle this case, ...
function invertapply(::typeof(dupl), t, y, ϕ::trait(contract))
end

# TODO
# How to specify different contractions
# How to have a better solution than tagtraits here
# -- Could have Trait{}