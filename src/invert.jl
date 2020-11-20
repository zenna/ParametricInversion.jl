export invert, invertapply, cycle, cycleir
import Mjolnir
using IRTools.Inner: Variable, argtypes, arguments
const PI = ParametricInversion

"Constant"
struct PIConstant{T}
  value::T
end

struct PIContext
  cfg::CFG
  fwd2inv::VarMap                     # Mapping between variable names in forward and inverse
  fwd2invmerged::Dict{Variable, Variable} # Maps variable to merged variable
  paramarg::Variable                  # Variable of params (todo: make this dynamicctx)
  invinarg::Variable                  # argument for input to the inverse
  vartypes::Dict{Variable, Type} 
  fwd2inv_block::Dict{BranchBlock, BlockId} # maps blockbranch in forward to inverse block id
end

# Creates a block in inverse for each branch point in forward
# Rather than have one block in inverse for one block in forward we have many
# This is because arriving in inverse direction at different branch points
# means that different variables in the block are known, and potentailly
# different subsets of statements are necessary to invert
function initinverseblocks!(ir, invir, fwd2inv, invinarg)
  fwd2inv_block = Dict{BranchBlock, BlockId}()
  for b in blocks(ir)
    for (i, br) in enumerate(branches(b))
      if IRTools.isreturn(br)
        # @assert false
        # @show IRTools.returnvalue(br)
        entryblock = 1
        add!(fwd2inv, IRTools.returnvalue(br), entryblock, invinarg)
        fwd2inv_block[(branch = i, block = b.id)] = 1 # zt: is this correct
      else
        invb = IRTools.block!(invir)
        for arg in arguments(br)
          invarg = argument!(invb; insert = false)
          isvar(arg) && add!(fwd2inv, arg, invb.id, invarg)
          # if isvar(arg)
          #   add!(fwd2inv, arg, invb.id, invarg)
          # else
          #   # ZT: FIXME if branchpoint has constant then in inverse direction
          #   # we have information about output variables of source/child
          #   nothing
          # end
        end
        fwd2inv_block[(branch = i, block = b.id)] = invb.id
      end
    end
  end
  # display(fwd2inv_block)
  fwd2inv_block
end

# Initialise inverse ir with necessary arguments and analyze fwdir to produce context
function setup!(ir, invir)
  invb = IRTools.block(invir, 1)
  selfarg = IRTools.argument!(invb)     # self
  farg = IRTools.argument!(invb)        # f
  typearg = IRTools.argument!(invb)     # types
  invinarg = IRTools.argument!(invb)    # input to inverse
  paramarg = IRTools.argument!(invb)    # parameters
  cfg = build_cfg(ir)

  vtypes = vartypes(ir)
  fwd2inv = VarMap()
  fwd2invmerged = Dict{Variable, Variable}()
  fwd2inv_block = initinverseblocks!(ir, invir, fwd2inv, invinarg)
  ctx = PIContext(cfg, fwd2inv, fwd2invmerged, paramarg, invinarg, vtypes, fwd2inv_block)
end

# Add return statement to each fwd input clone
function addreturn!(b::Block, invb::Block, ctx::PIContext)
  invretblocks = filter(bbr -> bbr.block == 1, keys(ctx.fwd2inv_block))
  # display(ctx.fwd2inv)
  if b.id == 1
    IRTools.return!(invb, invb)
    arginv = [getjoin!(arg, invb, ctx) for arg in fargs(b)]
    tpl = IRTools.xcall(Base, :tuple, arginv...)
    retvar = push!(invb, tpl)
    IRTools.return!(invb, retvar)
  end
end

"invert block `b`, store result in `invb`, assume v ∈ `knownvars` is known"
function invert!(b::Block, invb::Block, ctx::PIContext, knownvars::Set{Variable})
  reversestatementssimple!(b, invb, ctx, knownvars)
  addbranches!(b, invb, ctx)
  addreturn!(b, invb, ctx)
  invb
end

# "Undo each operation statement `%a = f(%x, %y, %z)` in `b`, add to `invb`"
# function reversestatements!(b::Block, invb::Block, ctx::PIContext, knownvars::Set{Variable})
#   for lhs in reverse(keys(b))
#     @show knownvars
#     @show stmt = b[lhs]
#     @show stmtvars_ = stmtvars(stmt)
#     @show unknownvars = setdiff(stmtvars_, knownvars)
#     @show axes = [stmtvars_; lhs]
#     f = stmt.expr.args[1]
    
#     @show axesids = [i for (i, axis) in enumerate(axes) if axis in unknownvars]
#     want = Axes{axesids...}
#     @show atypes = stmtargtypes(stmt, ctx.vartypes)
#     # getthething(stmt, axesids)
#     inv_stmt = xcall(ParametricInversion, :choose, f, atypes, want, ctx.paramarg)
#     union!(knownvars, unknownvars)
#     var = push!(invb, inv_stmt)

#     # add!(ctx.fwd2inv, lhs, invb.id, )

#     ## So ignoring the constants,
#     ## Let's assume for the minute that we want all teh parameters
#     ## Wanted vars is everything that's not constant
#     ## 
#     println("\n")
#   end
#   invb
# end

"Head of expression defined by statement"
head(stmt::Statement) =  stmt.expr.args[1]

"Returns axes_ where f(s) is true"
function saxes(s)
  coords = [s.var; s.stmt.expr.args[2:end]]
  [(i = i, val = v) for (i, v) in enumerate(coords)]
end

statements(b::Block) = collect((var = k, stmt = b[k]) for k in keys(b))

function getjoin!(v, b, ctx)
  # display(ctx.fwd2invmerged)
  if v in keys(ctx.fwd2invmerged)
    return ctx.fwd2invmerged[v]
  else
    # display(ctx.fwd2inv)
    invv = ctx.fwd2inv[(v, b.id)]
    # Singleton, don't bother invdupl
    if length(invv) == 1
      v_ = ctx.fwd2invmerged[v] = first(invv)
    else
      mergestmt = xcall(PI, :invdupl, invv...)
      v_ = push!(b, mergestmt)
      ctx.fwd2invmerged[v] = v_
    end
    return v_
  end
end

function reversestatementssimple!(b::Block, invb::Block, ctx::PIContext, knownvars::Set{Variable})
  # THIS IS A little less  HORRID!!

  i(x) = x.i
  val(x) = x.val

  for s in reverse(statements(b))
    # axes of all outputs that are variables
    targetaxes = Axes{i.(filter(a -> a.i != 1 && isvar(a.val), saxes(s)))...}
    # We know the fwd input and any constants
    knownaxes = Axes{i.(filter(a -> a.i == 1 || !isvar(a.val), saxes(s)))...}

    @assert !isempty(ctx.fwd2inv[(s.var, invb.id)])

    consts = val.(filter(a -> !isvar(a.val), saxes(s)))
    arg = getjoin!(s.var, invb, ctx)
    args = [arg; consts]

    invstmt = xcall(PI, :choose, head(s.stmt), stmtargtypes(s.stmt, ctx.vartypes),
                     targetaxes, knownaxes, args..., ctx.paramarg)
    var = push!(invb, invstmt)

    # detuple
    stmtvars_ = stmtvars(s.stmt)
    for (i, v) in enumerate(stmtvars_)
      v_ = push!(invb, xcall(Core, :getfield, var, i))
      add!(ctx.fwd2inv, v, invb.id, v_)
    end
  end
  invb
end

# Add branches in inverse direction from block to its predecessors (in forward)
function addbranches!(b, invb::Block, ctx)
  branches = incomingbranches(b)
  isempty(branches) && return invb  # No incoming branches, nothing to do!
  
  # Parametrically choose among possible incoming edges
  parentbids = tuple((ctx.fwd2inv_block[bbr] for bbr in branches)...)
  chosen = push!(invb, xcall(ParametricInversion, :choosebranch, parentbids, ctx.paramarg))

  # For each parent make a branch point
  for (i, bbr) in enumerate(branches)
    pa = IRTools.block(b.ir, bbr.block)
    br = IRTools.branches(pa)[bbr.branch] # zt: rename bbr.branch to bbr.brid
    destinvb = ctx.fwd2inv_block[bbr]
    stmt = xcall(Base, :(!=), chosen, destinvb)

    # Leave last branch conditionlessss
    condition = i < length(branches) ? push!(invb, stmt) : nothing

    invargs = []
    # This needs to be fwd to inverse in this block
    # display(ctx.fwd2inv)
    for fwdarg in arguments(b)
      k = (fwdarg, invb.id)
      zoww = ctx.fwd2inv[k]
      if length(zoww) == 1
        push!(invargs, first(zoww))
      else
        @assert false
      end
    end
    IRTools.branch!(invb, destinvb, invargs...; unless = condition)
  end
end

"When entering `block` at branchpoint `brid`, which variables are known?"
function knownvars(block, brid::BranchId)
  known_ = Set{Variable}()
  # Go in reverse order from branch upwards
  # Because we know all the conditions above (and including)
  # the branch point
  for i = brid:-1:1
    br = IRTools.branches(block)[brid]
    for a in br.args
      isvar(a) && push!(known_, a)
    end
    isvar(br.condition) && push!(known_, br.condition)
  end
  known_
end

"`ir::IR` that computes inverse inverse of `ir`"
function invert(ir::IR)
  invir = IR()        # Invert IR (has one block already)
  ctx = setup!(ir, invir) 

  for (brr, invbid) in ctx.fwd2inv_block
    invb = IRTools.block(invir, invbid)
    b = IRTools.block(ir, brr.block)
    known_ = knownvars(b, brr.branch)
    invert!(b, invb, ctx, known_)
  end
  return invir
end

function invertir(f::Type{F}, t::Type{T}) where {F, T}
  fwdir = Mjolnir.trace(Mjolnir.Defaults(), F, t.parameters...)
  IRTools.explicitbranch!(fwdir)
  invir = invert(fwdir)
end

invertir(f::Function, types::NTuple{N, DataType}) where {N} = 
  invertapply(f, Base.to_tuple_type(types))

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

Parametric inverse application of method `f(::t...)` to `args` with parameters `φ`
# Inputs:
`f` - function to invert
`t` - Tuple of types which determines method of `f` to invert
`arg` - Input to inverse method
`φ` - Parameter values

```
f(x, y, z) = x * y + z
x, y, z = invertapply(f, Tuple{Float64, Float64, Float64}, 2.3, rand(3))
@assert f(x, y, z) == 2.3
```
"""
@generated function invertapply(f, t::Type{T}, arg, φ) where T
  1+1
  return invertapplytransform(f, T)
end

function invertapply(f, types::NTuple{N, DataType}, arg, φ) where N
  invertapply(f, Base.to_tuple_type(types), arg, φ)
end

# zt - Fixme this is type unstable
"`cycle(f, args...)` `xs_` such that f⁻¹(f(args...))"
cycle(φ, f, args...) =
  invertapply(f, Base.typesof(args...), f(args...), φ)

cycleir(f, args...) =
  invertir(typeof(f), Base.typesof(args...))

cycle(f, args...) = 
  cycle(defϕ(), f, args...)

"Default paramter space"
defϕ() = rand(10)