export invert
using Mjolnir
using IRTools.Inner: Variable, argtypes, arguments

const VarMap = Dict{Variable, Vector{Variable}}

struct PIContext
  cfg::CFG
  fwd2inv::VarMap                   # Mapping between variable names in forward and inverse
  fwdtypes::Dict{Variable, Type}    # Mapping between all variable names to type in forward direction
  pathvar::Variable                 # Variable of path (todo: store in context?)
  param_arg::Variable               # Variable of params (todo: make this dynamicctx)
  invinarg::Variable                # argument for input to the inverse
end

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
function invert!(b::Block, invb::Block, ctx::PIContext) 
  if IRTools.isreturn(b)
    out = IRTools.returnvalue(b)
    ctx.fwd2inv[out] = [ctx.invinarg]
  end

  for branch in ctx.cfg.cfg[b.id].outgoing
    if branch.condition != nothing
      # TODO: HACK: fix this. this just makes all condition variables false
      #   Instead, use the last element in the path array in ctx.pathvar
      newvar = push!(invb, false)
      set!(ctx.fwd2inv, branch.condition, newvar)
    end
  end
  # Mapping between argument variables and their types
  # since this is not accessible with b[var].type for arguments
  # like for all other variables/statements
  argtype_map = Dict{IRTools.Variable, Type}()
  argtype_map = Dict{Variable, Type}(zip(arguments(b), argtypes(b)))

  # for i in 1:length(IRTools.arguments(b))
  #   arg = IRTools.arguments(b)[i]
  #   argtype = IRTools.argtypes(b)[i]
  #   argtype_map[arg] = argtype
  # end

  # In reverse order: for each statement in b of form `a = f(x, y)`
  # `
  MAGIC = 1  # FIXME
  for lhs in reverse(keys(b))
    stmt = b[lhs]
    args = stmt.expr.args[2:end]
    arg_types = []  # todo: what are these
    constants = []  # todo: what is this

    # Build up tuples of the types for each statement's
    # input/output so we can route to the right inverse method.
    for arg in args
      if typeof(arg) != IRTools.Variable
        push!(arg_types, PIConstant{typeof(arg)})
        push!(constants, PIConstant{typeof(arg)}(arg))
      elseif arg in keys(ctx.fwdtypes)
        push!(arg_types, ctx.fwdtypes[arg])
      else
        error("unknown arg", arg)
      end
    end
    arg_types = Tuple{arg_types...}
    constants = tuple(constants...)

    # Add inverse statement
    # Todo: there may be multiple values, implication of choosing MAGIC?
    pi_inp = ctx.fwd2inv[lhs][MAGIC]    # Input to inverse is output of f app in fwd 
    output_type = stmt.type
    # TODO: Do we want to always have a constants array, sometimes empty (giving consistent primitive signatures)
    #       or like here where the constant array is only present if it is nonempty?
    if size(constants, 1) > 0 
      inv_stmt = xcall(ParametricInversion, :invertapply, stmt.expr.args[1], arg_types, constants, pi_inp, ctx.param_arg)
    else
      inv_stmt = xcall(ParametricInversion, :invertapply, stmt.expr.args[1], arg_types, pi_inp, ctx.param_arg)
    end
    retvar = push!(invb, inv_stmt)
    

    # For each statement in invb of form `a = invapply(+, x) ``
    # produce statements: x = a[1], y = a[2]
    if length(args) == 0
      error("Cannot invert functions of no arguments")
    elseif length(args) == 1
      # TODO: should unary and nary be handlded differently? do unary inverses return value
      # or tuple?
      set!(ctx.fwd2inv, args[1], retvar)
    else
      for (i, arg) in enumerate(args)
        # Skip mapping constants
        if typeof(arg) != IRTools.Variable
          continue
        end
        stmt = xcall(Base, :getindex, retvar, i)
        retvar2 = push!(invb, stmt)
        set!(ctx.fwd2inv, arg, retvar2)
        # @show fwd2inv
      end
    end
    # display(invb)
    # println()
    # @show invb
    # @show args => xcall(ParametricInversion, :invert, stmt.expr.args[1], lhs)
  end

  # Todo: This should probably be at the top no?
  # Add this block to the path
  push!(invb, xcall(Base, :push!, ctx.pathvar, b.id))

  # Tuple outputs
  rettuple = []
  
  # If a variable is used multiple times in forward function then
  # fwd2inv[var] will contain multiple values, one for each usage
  # We must then invdupl them to produce output of the parametric inverse for that
  # one input to the forward function
  for var in arguments(b)[2:end]
    duplicates = ctx.fwd2inv[var]
    if length(duplicates) == 1
      push!(rettuple, duplicates[1])
    else
      invdupl_stmt = xcall(ParametricInversion, :invdupl, duplicates...)
      invdupl_retvar = push!(invb, invdupl_stmt)
      push!(rettuple, invdupl_retvar)
    end
  end

  addbranches!(invb, ctx.cfg.cfg[b.id].incoming, ctx)
  
  # TODO think??: only return if we are in the first block in the forward direction?
  if b.id == 1
    rettuple = xcall(Core, :tuple, rettuple...)
    retval = push!(invb, rettuple)
    IRTools.return!(invb, retval)
  end

  invb
end

# TODO: use phi to actually choose a branch intelligently
# TODO: add arguments like path through blocks? depends on our value addressing scheme.
function choosebranch(branches, φ)
  # idx = rand(1:size(branches,1))
  # println("choosebranch: ", branches)
  # println("branches[idx]: ", branches[idx], typeof(branches[idx]))
  
  # # TODO: might be wrong?? specifically, return branches.
  # return branches[idx][1]
  return 1
end

function addbranches!(invb::Block, branches::Array{Tuple{Branch, Int64}}, ctx)
  chosen = push!(invb, xcall(ParametricInversion, :choosebranch, branches, ctx.param_arg))
  for b in branches
    branch = b[1]  ## zt: todo Use a named tuple
    blocknum = b[2]
    condition = push!(invb, xcall(Base, :(!=), chosen, blocknum + 1)) # blockid = invblockid + 1
    invargs = []
    for fwdarg in branch.args
      if fwdarg in keys(ctx.fwd2inv)
        push!(invargs, ctx.fwd2inv[fwdarg][1])
      else
        # TODO: HACK: we must parametrically choose this argument
        push!(invargs, 0)
      end
    end
    IRTools.branch!(invb, blocknum+1, invargs, condition)
  end
end

# Need n arguments added to invb where n is the 
# size of the union of all the outgoing branch arguments 
# in the forward direction (determined by the cfg for block b in fwd direction). 
# We add these arguments, then update the fwd2inv 
# map with these arguments. 
function addblockargs!(invb::Block, b, ctx)
  argset = Set()
  for branch in ctx.cfg.cfg[b].outgoing
    for arg in branch.args
      if typeof(arg) != Variable || arg in argset
        continue
      end
      invarg = argument!(invb)
      set!(ctx.fwd2inv, arg, invarg)
      push!(argset, arg)
    end
  end
end
  
function invert(ir::IR)
  invir = IR()    # Invert IR (has one block already)
  invb = IRTools.block(invir, 1)

  # Inputs  
  selfarg = IRTools.argument!(invb)     # self
  farg = IRTools.argument!(invb)        # f
  typearg = IRTools.argument!(invb)     # types
  invinarg = IRTools.argument!(invb)    # input to inverse
  param_arg = IRTools.argument!(invb)    # Parameters

  pathvar = push!(invb, xcall(Base, :vect))

  cfg = build_cfg(ir)
  fwdtypes = build_fwdtypes(ir)
  ctx = PIContext(cfg, VarMap(), fwdtypes, pathvar, param_arg, invinarg)


  # Add possible starting points to block 1 of inverse direction
  # Convention: (block # in inverse direction) = (block # in forward direction) + 1
  addbranches!(invb, cfg.return_blocks, ctx)

  for b in 1:size(ir.blocks, 1)
    invb_new = IRTools.block!(invir)
    addblockargs!(invb_new, b, ctx)
    invert!(IRTools.block(ir, b), invb_new, ctx)
  end
  
  invir
end


dummy() = return
# untvar(t::TypeVar) = t.ub
# untvar(x) = x

# function makemeta(T; world = IRTools.Inner.worldcounter())
#   F = T.parameters[1]
#   _methods = Base._methods_by_ftype(T, -1, world)
#   type_signature, sps, method = last(_methods)
#   type_signature, sps, method = last(_methods)
#   sps = Core.svec(map(untvar, sps)...)
#   ci = code_lowered(dummy, Tuple{})[1]
#   IRTools.Meta(method, ci, method.nargs, sps)
# end

function invertapplytransform(f::Type{F}, t::Type{T}, φ) where {F, T}
  # Lookup forward function IR
  fwdir = Mjolnir.trace(Mjolnir.Defaults(), F, t.parameters...)
  nothing

  # Construct inverse IR
  invir = invert(fwdir)
  Core.println(invir)

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
  return invertapplytransform(f, T, φ)
end

function invertapply(f, types::NTuple{N, DataType}, arg, φ) where N
  invertapply(f, Base.to_tuple_type(types), arg, φ)
end

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

struct PIConstant{T}
  value::T
end
