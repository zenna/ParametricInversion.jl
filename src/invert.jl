const VarMap = Dict{Variable, Vector{Variable}}

function set!(vm::VarMap, k, v)
  if k in keys(vm)
    push!(vm[k], v)
  else
    vm[k] = [v]
  end
end

# struct InvDuplClass
#   out::Variable
#   inp::Vector{Variable}
# end

"""
Invert a basic block, put results in empty block `invb`

Example:
If The IR is

````
1: (%1, %2, %3, %4)
  %5 = %2 + %3 + 3
  %6 = %5 * %4
  %7 = Main.g(%6)
  return %7
```
The inverted IR is

```
1: (%8)
  %6 = inv(g, %7)
  %5_4 = inv(*, %6)
  %5 = getindex(%5_4, 1)
  %4 = getindex(%5_4, 2)

  %2_3 = inv(+, 5)
  %2 = getindex(%2_3, 1)
  %3 = getindex(%2_3, 2)
  %8 = tuple(%2, %3, %4)
  return %8
```
"""
function invert!(b::Block, invb::Block)
  # Inputs
  selfarg = IRTools.argument!(invb)     # self
  farg = IRTools.argument!(invb)        # f
  typearg = IRTools.argument!(invb)     # types
  invinarg = IRTools.argument!(invb)    # input to inverse
  paramarg = IRTools.argument!(invb)    # Parameters
  
  # Mapping between variable names in forward and inverse
  out = IRTools.returnvalue(b)
  fwd2inv = VarMap(out => [invinarg])
  MAGIC = 1  # FIXME
  for lhs in reverse(keys(b))
    stmt = b[lhs]
    args = stmt.expr.args[2:end] 

    # Add inverse statement
    piinp = fwd2inv[lhs][MAGIC]    # Input to inverse is output of f app in fwd 
    types = Any # FIXME: Actually pass types
    invsmt = xcall(ParametricInversion, :invert, stmt.expr.args[1], Any, piinp, paramarg)
    retvar = push!(invb, invsmt)
    
    if length(args) == 0
      @assert false "unhandled"
    elseif length(args) == 1
      set!(fwd2inv, args[1], retvar)
    else
      for (i, arg) in enumerate(args)
        stmt = xcall(Base, :getindex, retvar, i)
        retvar2 = push!(invb, stmt)
        set!(fwd2inv, arg, retvar2)
        # @show fwd2inv
      end
    end
    # @show invb
    # @show args => xcall(ParametricInversion, :invert, stmt.expr.args[1], lhs)
  end

  # Tuple outputs and return
  rettuple = xcall(Core, :tuple, (fwd2inv[var][MAGIC] for var in arguments(b)[2:end])...)
  retval = push!(invb, rettuple)
  IRTools.return!(invb, retval)
  invb
end

function invert(ir::IR)
  invir = IR()    # Invert IR (has one block already)
  invert!(IRTools.block(ir, 1), IRTools.block(invir, 1))
  invir
end

cattype(::Type{F}, ::Type{Tuple{T1}}) where {F, T1} = Tuple{F, T1}
cattype(::Type{F}, ::Type{Tuple{T1, T2}}) where {F, T1, T2} = Tuple{F, T1, T2}
cattype(::Type{F}, ::Type{Tuple{T1, T2, T3}}) where {F, T1, T2, T3} = Tuple{F, T1, T2, T3}
cattype(::Type{F}, ::Type{Tuple{T1, T2, T3, T4}}) where {F, T1, T2, T3, T4} = Tuple{F, T1, T2, T3, T4}
# cattype(::Type{F}, ::Type{NTuple{N, T}}) where {F, N, T} = Tuple{F, T1, T2, T3}


dummy() = return
untvar(t::TypeVar) = t.ub
untvar(x) = x

function makemeta(T; world = IRTools.Inner.worldcounter())
  F = T.parameters[1]
  _methods = Base._methods_by_ftype(T, -1, world)
  type_signature, sps, method = last(_methods)
  type_signature, sps, method = last(_methods)
  sps = Core.svec(map(untvar, sps)...)
  ci = code_lowered(dummy, Tuple{})[1]
  IRTools.Meta(method, ci, method.nargs, sps)
end

function invertapplytransform(f::Type{F}, t::Type{T}) where {F, T}
  # Lookup forward function IR
  TS = cattype(F, T)
  m = IRTools.meta(TS)
  fwdir = IRTools.IR(m)
  nothing

  # Construct inverse IR
  invir = invert(fwdir)
  Core.print(invir)

  # Finalize
  argnames_ = [Symbol("#self#"), :f, :t, :arg, :φ]
  ci = code_lowered(dummy, Tuple{})[1]
  ci.slotnames = [argnames_...]
  return update!(ci, invir)
end

"""
`invertapply(f, t::Type{T}, arg, φ)`

Parametric inverse application of method `f` to `args` with parameters `φ`

```
f(x, y, z) = x * y + z
invertapply(f, Tuple{Int, Int, Int}, 2.3, rand(3))
```

"""
@generated function invertapply(f, t::Type{T}, arg, φ) where T
  invertapplytransform(f, T)
  # # Lookup forward function IR
  # TS = cattype(f, T)
  # m = IRTools.meta(TS)
  # fwdir = IRTools.IR(m)
  # nothing

  # # Construct inverse IR
  # invir = invert(fwdir)
  # Core.print(invir)

  # # Finalize
  # argnames_ = [Symbol("#self#"), :f, :t, :arg, :φ]
  # ci = code_lowered(dummy, Tuple{})[1]
  # ci.slotnames = [argnames_...]
  # return update!(ci, invir)
end

invertapply(f, types::NTuple{N, DataType}, arg, φ) where N =
  invertapply(f, Base.to_tuple_type(types), arg, φ)

#### Questions
# For compound object, e.g. inverse of  %9 = %8 + %2
# - decompose straightaway or wait until needed? 
# - Is there a chance of a variable being reused more than once in inverse
# - TO be reused more than once we need it to be on LHS more than once which is forbidden
# - 
# How to handle the parameter addressing
# 

# Need to  encode
# 1. Mapping between variables in inverse
# 

struct VarTuple{N}
  vars::NTuple{N, Variable}
end
