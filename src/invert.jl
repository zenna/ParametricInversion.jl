export invert
using Mjolnir

const VarMap = Dict{Variable, Vector{Variable}}

function set!(vm::VarMap, k, v)
  if k in keys(vm)
    push!(vm[k], v)
  else
    vm[k] = [v]
  end
end

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
  param_arg = IRTools.argument!(invb)   # Parameters
  
  # Mapping between variable names in forward and inverse
  out = IRTools.returnvalue(b)
  fwd2inv = VarMap(out => [invinarg])

  # Mapping between argument variables and their types
  # since this is not accessible with b[var].type for arguments
  # like for all other variables/statements
  argtype_map = Dict{IRTools.Variable, Type}()

  # Start at 2 because 1 is the function
  for i in 2:size(IRTools.arguments(b), 1)
    arg = IRTools.arguments(b)[i]
    argtype = IRTools.argtypes(b)[i]
    argtype_map[arg] = argtype
  end

  MAGIC = 1  # FIXME
  for lhs in reverse(keys(b))
    stmt = b[lhs]
    args = stmt.expr.args[2:end]
    arg_types = []
    constants = []
    # Build up tuples of the types for each statement's
    # input/output so we can route to the right inverse method.
    for arg in args
      if typeof(arg) != IRTools.Variable
        push!(arg_types, PIConstant{typeof(arg)})
        push!(constants, PIConstant{typeof(arg)}(arg))
      elseif arg in keys(argtype_map)
        push!(arg_types, argtype_map[arg])
      else
        push!(arg_types, b[arg].type)
      end
    end
    arg_types = Tuple{arg_types...}
    constants = tuple(constants...)

    # Add inverse statement
    pi_inp = fwd2inv[lhs][MAGIC]    # Input to inverse is output of f app in fwd 
    output_type = stmt.type
    # TODO: Do we want to always have a constants array, sometimes empty (givign consistent primitive signatures)
    #       or like here where the constant array is only present if it is nonempty?
    if size(constants, 1) > 0 
      inv_stmt = xcall(ParametricInversion, :invertapply, stmt.expr.args[1], arg_types, constants, pi_inp, param_arg)
     else 
      inv_stmt = xcall(ParametricInversion, :invertapply, stmt.expr.args[1], arg_types, pi_inp, param_arg)
    end
    retvar = push!(invb, inv_stmt)
    
    # display(stmt)
    # @show fwd2inv
    if length(args) == 0
      error("Cannot current invert nullary functions see #10")
    elseif length(args) == 1
      set!(fwd2inv, args[1], retvar)
    else
      for (i, arg) in enumerate(args)
        # Skip mapping constants
        if typeof(arg) != IRTools.Variable
          continue
        end
        stmt = xcall(Base, :getindex, retvar, i)
        retvar2 = push!(invb, stmt)
        set!(fwd2inv, arg, retvar2)
        # @show fwd2inv
      end
    end
  end

  # Tuple outputs
  rettuple = []
  
  # If a variable is used multiple times in forward function then
  # fwd2inv[var] will contain multiple values, one for each usage
  # We must then invdupl them to produce output of the parametric inverse for that
  # one input to the forward function
  for var in arguments(b)[2:end]
    duplicates = fwd2inv[var]
    if length(duplicates) == 1
      push!(rettuple, duplicates[1])
    else
      invdupl_stmt = xcall(ParametricInversion, :invdupl, duplicates...)
      invdupl_retvar = push!(invb, invdupl_stmt)
      push!(rettuple, invdupl_retvar)
    end
  end

  rettuple = xcall(Core, :tuple, rettuple...)
  retval = push!(invb, rettuple)
  IRTools.return!(invb, retval)
  invb
end
  
function invert(ir::IR)
  invir = IR()    # Invert IR (has one block already)
  invert!(IRTools.block(ir, 1), IRTools.block(invir, 1))
  invir
end

function invertir(f::Type{F}, t::Type{T}) where {F, T}
  fwdir = Mjolnir.trace(Mjolnir.Defaults(), F, t.parameters...)
  invir = invert(fwdir)
end

function invertapplytransform(f::Type{F}, t::Type{T}) where {F, T}
  invir = invertir(f, t)

  # Finalize
  # zt - I wrote this (I think) but I'm not sure what they do?
  dummy() = return
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
  return invertapplytransform(f, T)
end

function invertapply(f, types::NTuple{N, DataType}, arg, φ) where N
  invertapply(f, Base.to_tuple_type(types), arg, φ)
end

struct VarTuple{N}
  vars::NTuple{N, Variable}
end

struct PIConstant{T}
  value::T
end
