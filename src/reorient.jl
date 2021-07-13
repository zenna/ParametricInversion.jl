import Mjolnir
using IRTools.Inner: Variable, argtypes, arguments

export reorientapply

"Constant"
struct PIConstant{T}
  value::T
end

# State carried around during inversion
struct PIContext
  ir::IR
  invir::IR
  cfg::CFG
  fwd2inv::VarMap                     # Mapping between variable names in forward and inverse
  fwd2invmerged::Dict{Variable, Variable} # Maps variable to merged variable
  paramarg::Variable                  # Variable of params (todo: make this dynamicctx)
  invinarg::Variable                  # argument for input to the inverse
  vartypes::Dict{Variable, Type} 
  fwd2inv_block::Dict{BranchBlock, BlockId} # maps bbr::BranchBlock in forward to inverse block id
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
  ctx = PIContext(ir, invir, cfg, fwd2inv, fwd2invmerged, paramarg, invinarg, vtypes, fwd2inv_block)
end

# Add return statement to each fwd input clone
function addreturn!(b::Block, invb::Block, ctx::PIContext)
  invretblocks = filter(bbr -> bbr.block == 1, keys(ctx.fwd2inv_block))
  # display(ctx.fwd2inv)
  if b.id == 1 # zt: this is incomplete -- it's currently not usign invretblocks
    IRTools.return!(invb, invb)
    arginv = [getjoin!(arg, invb, ctx) for arg in fargs(b)]
    tpl = IRTools.xcall(Base, :tuple, arginv...)
    retvar = push!(invb, tpl)
    IRTools.return!(invb, retvar)
  end
end

"invert block `b`, store result in `invb`, assume v ∈ `knownvars` is known"
function invert!(b::Block, invb::Block, ctx::PIContext, knownvars::Dict{Variable, Any})
  reversestatementssimple!(b, invb, ctx, knownvars)
  addbranches!(b, invb, ctx)
  addreturn!(b, invb, ctx)
  invb
end

"Undo each operation statement `%a = f(%x, %y, %z)` in `b`, add to `invb`"
function reversestatements!(b::Block, invb::Block, ctx::PIContext, knownvars::Dict{Variable, Any})
  for lhs in reverse(keys(b))
    @show knownvars
    @show stmt = b[lhs]
    @show stmtvars_ = stmtvars(stmt)
    @show unknownvars = setdiff(stmtvars_, knownvars)
    @show axes = [stmtvars_; lhs]
    f = stmt.expr.args[1]
    
    @show axesids = [i for (i, axis) in enumerate(axes) if axis in unknownvars]
    want = Places{Tuple{axesids...}}
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

"For statement of the form `v1 = f(v2, v3, ..., vn)` produces [v1, v2, ..., vn]"
function enumplaces(vs)
  coords = [vs.var; vs.stmt.expr.args[2:end]]
  [(i = i + 1, val = v) for (i, v) in enumerate(coords)]
end
# baxes(s) = [s.var; s.stmt.expr.args[2:end]]

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

function reversestatementssimple!(b::Block, invb::Block, ctx::PIContext, knownvars::Dict{Variable, Any})
  i(x) = x.i
  val(x) = x.val
  isretvar(i) = i == 2
  
  methodid_ = methodid(ctx.ir)

  # In reverse order, for each statement 
  for vs in reverse(varstatements(b))
    # axes of all outputs that are variables
    targetaxes = places((i for (i, v) in enumplaces(vs) if isvar(v) && !isretvar(@show(i))))
    @show targetaxes
    # targetaxes = places Places{Tuple{i.(filter(a -> a.i != 1 && isvar(a.val), saxes(vs)))...}}
    # We know the fwd input and any constants
    knownaxes = places((i for (i, v) in enumplaces(vs) if !isvar(v) || isretvar(i)))
    # knownaxes = Places{Tuple{i.(filter(a -> a.i == 1 || !isvar(a.val), saxes(vs)))...}}

    # @assert !isempty(ctx.fwd2inv[(vs.var, invb.id)])
    @assert haskey(knownvars, vs.var) || !isempty(ctx.fwd2inv[(vs.var, invb.id)])
    if isvar(knownvars[vs.var])
      arg = getjoin!(vs.var, invb, ctx) # zt : does this handle multiple merges, correctly?
    else
      arg = knownvars[vs.var]
    end
    consts = val.(filter(a -> !isvar(a.val), enumplaces(vs)))
    args = [arg; consts] # zt: rename args to inverse

    # Location
    loc = Loc(methodid_, vs.var)

    invstmt = xcall(PI, :choose, ctx.paramarg, loc, head(vs.stmt), stmtargtypes(vs.stmt, ctx.vartypes),
                     targetaxes, knownaxes, args...)
    var = push!(invb, invstmt)

    # detuple
    stmtvars_ = stmtvars(vs.stmt)
    for (i, v) in enumerate(stmtvars_)
      v_ = push!(invb, xcall(Core, :getfield, var, i))
      add!(ctx.fwd2inv, v, invb.id, v_)
      # add new known vars so next iteration
      # knownvars has full set of known variables
      updateknown!(knownvars, v, v)
    end
  end
  invb
end

function choosebranch end 

# Add branches to invb from each block to its predecessors (in forward)
function addbranches!(b, invb::Block, ctx)
  branches = incomingbranches(b)
  isempty(branches) && return invb  # No incoming branches, nothing to do!
  
  # Parametrically choose among possible incoming edges
  parentbids = tuple((ctx.fwd2inv_block[bbr] for bbr in branches)...)
  chosen = push!(invb, xcall(PI, :choosebranch, parentbids, ctx.paramarg)) # zt: specialise case when there's only one parent

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
      mergedvar = getjoin!(fwdarg, invb, ctx)
      push!(invargs, mergedvar)
    end
    IRTools.branch!(invb, destinvb, invargs...; unless = condition)
  end
end

#dm: we might not want to update the val if one already exists?
#dm: how do we choose? is this possible?
function updateknown!(known, var, val)
  known[var] = val
end

"""
When entering `block` at branchpoint `brid`, which variables are known?
"""
function knownvars(block, brid::BranchId)
  known_ = Dict{Variable, Any}()
  # Go in reverse order from branch upwards
  # Because we know all the conditions above (and including)
  # the branch point
  for i = brid:-1:1
    br = IRTools.branches(block)[i]
    for a in br.args
      isvar(a) && updateknown!(known_, a, a)
    end
    isvar(br.condition) && updateknown!(known_, br.condition, i != brid)
  end
  known_
end

"`ir::IR` that computes inverse inverse of `ir`"
function invert(ir::IR)
  invir = IR()        # Invert IR (has one block already)
  ctx = setup!(ir, invir)

  # For each block in forward create inverse block invir
  for (bbr, invbid) in ctx.fwd2inv_block
    invb = IRTools.block(invir, invbid)
    b = IRTools.block(ir, bbr.block)
    known_ = knownvars(b, bbr.branch)
    invert!(b, invb, ctx, known_)
  end
  return invir
end

function reorientir(f::Type{F}, t::Type{T}, target, known) where {F, T}
  fwdir = Mjolnir.trace(Mjolnir.Defaults(), F, t.parameters...)
  IRTools.explicitbranch!(fwdir)  # IR-transforms assumes no implicit branching
  fwdir |> IRTools.expand! |> IRTools.explicitbranch!
  invir = invert(fwdir)
end

reorientir(f::Function, types::NTuple{N, DataType}) where {N} = 
  reorientir(typeof(f), Base.to_tuple_type(types))

# TODO, will have to add target to this,
# TODO: What about given.  There's the valus themselves, e.g. the input to
# inverse in case of inversion, as well as the tpe of information
function reorient(f::Type{F}, t::Type{T}, target, known) where {F, T}
  invir = reorientir(f, t, target, known)

  # Finalize
  # zt - I wrote this (I think) but I'm not sure what they do?
  dummy() = return
  argnames_ = [Symbol("#self#"), :f, :t, :arg, :θ]
  ci = code_lowered(dummy, Tuple{})[1]
  ci.slotnames = [argnames_...]
  return update!(ci, invir)
end

@generated function choose(f, t::Type{T}, target::Type{<:Places}, known::Type{<:Places}, z, θ) where T
  return reorient(f, T, target, known)
end