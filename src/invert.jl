export invert, invertapply, cycle
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
  fwd2inv_block = initinverseblocks!(ir, invir, fwd2inv, invinarg)
  ctx = PIContext(cfg, fwd2inv, paramarg, invinarg, vtypes, fwd2inv_block)
end

# potenial bug Maybe utnary
funcarguments(b) = arguments(b)[2:end]

# Add return statement to each fwd input clone
function addreturn!(b::Block, invb::Block, ctx::PIContext)
  invretblocks = filter(bbr -> bbr.block == 1, keys(ctx.fwd2inv_block))
  # display(ctx.fwd2inv)
  if b.id == 1
    IRTools.return!(invb, invb)
    # FIXME Replace with first 
    arginv = [first(ctx.fwd2inv[(arg, invb.id)]) for arg in funcarguments(b)]
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

"Undo each operation statement `%a = f(%x, %y, %z)` in `b`, add to `invb`"
function reversestatements!(b::Block, invb::Block, ctx::PIContext, knownvars::Set{Variable})
  for lhs in reverse(keys(b))
    @show knownvars
    @show stmt = b[lhs]
    @show stmtvars_ = stmtvars(stmt)
    @show unknownvars = setdiff(stmtvars_, knownvars)
    @show axes = [stmtvars_; lhs]
    f = stmt.expr.args[1]
    
    @show axesids = [i for (i, axis) in enumerate(axes) if axis in unknownvars]
    want = Axes{axesids...}
    @show atypes = stmtargtypes(stmt, ctx.vartypes)
    # getthething(stmt, axesids)
    inv_stmt = xcall(ParametricInversion, :choose, f, atypes, want, ctx.paramarg)
    union!(knownvars, unknownvars)
    var = push!(invb, inv_stmt)

    # add!(ctx.fwd2inv, lhs, invb.id, )

    ## So ignoring the constants,
    ## Let's assume for the minute that we want all teh parameters
    ## Wanted vars is everything that's not constant
    ## 
    println("\n")
  end
  invb
end

# s(stmt, i) = 

function reversestatementssimple!(b::Block, invb::Block, ctx::PIContext, knownvars::Set{Variable})
  # THIS IS HORRID!!
  for lhs in reverse(keys(b))
    stmt = b[lhs]
    f = stmt.expr.args[1]
    atypes = stmtargtypes(stmt, ctx.vartypes)
    # + 1 because ith argument has axis id i + 1, since output id is 1
    axesids = [i + 1 for (i, v) in enumerate(stmt.expr.args[2:end]) if isvar(v)]
    want = Axes{axesids...}

    known_ = [i + 1 for (i, v) in enumerate(stmt.expr.args[2:end]) if !isvar(v)]
    knownaxes = [1; known_]
    known = Axes{knownaxes...}

    # Get the arguments
    lhsininv = ctx.fwd2inv[(lhs, invb.id)]
    @assert !isempty(lhsininv)

    # function mergevars!(lhsininv, invb)
    #   stmt = xcall(ParametricInversion, :invdupl, lhsininv...)
    #   push!(invb, stmt)
    # end

    # vmerged = mergevars!(lhsininv)

    arg = first(lhsininv)
    args = [arg; filter(x -> !isvar(x), stmt.expr.args[2:end])]

    # What's mssing?
      # What's known, the constants
    inv_stmt = xcall(ParametricInversion, :choose, f, atypes, want, known, args..., ctx.paramarg)
    var = push!(invb, inv_stmt)

    # Detuple
    stmtvars_ = stmtvars(stmt)
    for (i, v) in enumerate(stmtvars_)
      v_ = push!(invb, xcall(Core, :getfield, var, i))
      add!(ctx.fwd2inv, v, invb.id, v_)
    end
    # stmtvars_ = stmtvars(stmt)
    # for v in stmtvars_
    #   add!(ctx.fwd2inv, v, invb.id, var)
    # end
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

  # Invert return
  # ZT: remove this as a special case
  # b = blocks(ir)[end]
  # IRTools.isreturn(b) || error("Final block must be return block")
  # invb = IRTools.block(invir, 1)
  # known = Set{Variable}([IRTools.returnvalue(b)])
  # invert!(b, invb, ctx, known)

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
  return invertapplytransform(f, T)
end

function invertapply(f, types::NTuple{N, DataType}, arg, φ) where N
  invertapply(f, Base.to_tuple_type(types), arg, φ)
end

"`cycle(f, args...)` `xs_` such that f⁻¹(f(args...))"
cycle(φ, f, args...) =
  invertapply(f, Base.typesof(args...), f(args...), φ)

cycle(f, args...) = 
  cycle(defϕ(), f, args...)

"Default paramter space"
defϕ() = rand(10)