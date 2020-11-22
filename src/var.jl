export defθ

struct Var
  data::Dict{Any, Any}
end

struct VarProj{ID}
  var::Var
  loc::ID
end

project(var, loc) = VarProj(var, loc)
Base.getindex(var::Var, id) = project(var, id)

"Default paramter space"
defθ() = Var(Dict{Any, Any}())

function unit(vπ::VarProj, T = Float64)
  get!(() -> rand(T), vπ.var.data, (vπ.loc, unit, T))::T
end

function bools(vπ::VarProj)
  get!(() -> rand(Bool), vπ.var.data, (vπ.loc, bools))::T
end

function integers(vπ::VarProj, T = Int)
  get!(() -> rand(T), vπ.var.data, (vπ.loc, integers, T))::T
end

function addressmap(θ::Var)
  let ks = deepcopy(keys(θ))
    function (xs::AbstractVector)
      Dict{Any, Any}(ks[i] => xs[i] for i = 1:length(xs))
    end
  end
end
