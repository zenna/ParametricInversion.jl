export inverseparameters, pgfapply

"""

Parameters that can be used to invert to `x` from `y`
`parameters(f, types, args...)`

Produces parameters `θ` such that:

`inverseparameters(f, types, f(args...), θ) == args`

These parameters can be used for learning.
"""
function inverseparameters end
function choose(ϴ, ::typeof(+), ::Int2, ::Type{TZ}, ::Type{AB}, a, b)
  push!(ϴ.stack, (b,))
  return a+b
end

struct PgfContext
  ir::IR
  pgfir::IR
  fwd2pgf::Dict{Variable, Variable}
  thetavar::Variable
  vartypes::Dict{Variable, Type} 
  fwd2pgf_block::Dict{BlockId, BlockId}
end

function initpgfblocks!(ir::IR, pgfir::IR, fwd2pgf::Dict{Variable, Variable})
  fwd2pgf_block = Dict{BlockId, BlockId}()
  for b in IRTools.blocks(ir)
    pgfb = IRTools.block!(pgfir)
    fwd2pgf_block[b.id] = pgfb.id
    args = arguments(b)
    # remove "self" function arg
    if b.id == 1
      args = args[2:end]
    end
    for arg in args
       pgfarg = argument!(pgfb; insert=false)
      fwd2pgf[arg] = pgfarg
    end
    # thetaarg = argument!(pgfb) # maybe not necessary? use global ctx.thetavar?
  end
  fwd2pgf_block
end

# analgous to setup!
function setuppfg!(ir::IR, pgfir::IR)
  # make block 1
  pgfb = IRTools.block(pgfir, 1)
  selfarg = IRTools.argument!(pgfb; insert=false)
  # farg = IRTools.argument!(pgfb)

  fwd2pgf = Dict{Variable, Variable}()
  vtypes = vartypes(ir)

  #TODO: copy args from block 1 in fwd??
  pgfargs = []
  for arg in arguments(IRTools.block(ir, 1))[2:end] # exclude function arg
    pgfarg = argument!(pgfb; insert=false)
    push!(pgfargs, pgfarg)
  end

  fwd2pgf_block = initpgfblocks!(ir, pgfir, fwd2pgf)

  IRTools.branch!(pgfb, IRTools.block(pgfir, 2), pgfargs...)

  # construct thetas
  # printstmt = xcall(Base, :println, "testing print in IR")
  # printvar = push!(pgfb, printstmt)
  thetastmt = xcall(PI, :newthetas)
  thetavar = push!(pgfb, thetastmt)

  PgfContext(ir, pgfir, fwd2pgf, thetavar, vtypes, fwd2pgf_block)
end

# analagous to addbranches!
function editbranches!(b::Block, pgfb::Block, ctx::PgfContext)
  # at the end of pgfb
  # if there's a return, return theta param instead of value
  #   or (return value, theta)
  for br in IRTools.branches(b)
    pgfargs = map((arg)-> if isvar(arg) ctx.fwd2pgf[arg] else arg end, br.args)
    if isreturn(br)
      # TODO: maybe return (value, theta instead)
      IRTools.branch!(pgfb, 0, ctx.thetavar)
      continue
    end
    # println("branch: ", br)
    dest = ctx.fwd2pgf_block[br.block]
    pgfargs = map((arg)-> if isvar(arg) ctx.fwd2pgf[arg] else arg end, br.args)
    if br.condition === nothing
      IRTools.branch!(pgfb, dest, pgfargs...)
    else 
      if isvar(br.condition)
        pgfcondition = ctx.fwd2pgf[br.condition]
      else
        pgfcondition = br.condition
      end
      pgfcondition = if isvar(br.condition) ctx.fwd2pgf[br.condition] else br.condition end
      IRTools.branch!(pgfb, dest, pgfargs...; unless = pgfcondition)
    end
    
  end
end

# analagous to reversestatementssimple!
function pgfstatementsimple!(b::Block, pgfb::Block, ctx::PgfContext)
  i(x) = x.i
  val(x) = x.val
  
  methodid_ = methodid(ctx.ir)

  # println("pgfstatementsimple!", b.id, pgfb.id)

  stmt = xcall(PI, :updatepath, ctx.thetavar, b.id)
  _ = push!(pgfb, stmt)

  for s in statements(b)
    # println("stmt:", s)
    loc = Loc(methodid_, s.var)
    targetaxes = TZ;
    args = map((arg) -> if isvar(arg) ctx.fwd2pgf[arg] else arg end, s.stmt.expr.args[2:end])
    @assert(length(args) == length(s.stmt.expr.args[2:end]))
    # println("updated args: ", args)
    knownaxes = Axes{[i for i in 3:3+length(args)-1]...}
    # println("knownaxes ", knownaxes)

    stmt = xcall(PI, :choose, ctx.thetavar, loc, head(s.stmt), stmtargtypes(s.stmt, ctx.vartypes),
                     targetaxes, knownaxes, args...)
    var = push!(pgfb, stmt)
    ctx.fwd2pgf[s.var] = var
  end
  pgfb
end

# analagous to invert!
function pgfblock!(b::Block, pgfb::Block, ctx::PgfContext)
  # add this block to thetavar.path
  pgfstatementsimple!(b, pgfb, ctx)
  editbranches!(b, pgfb, ctx)
  pgfb
end

#analgous to invert
function pgf(ir::IR)
  pgfir = IR()
  ctx = setuppfg!(ir, pgfir)
  
  for (bid, pgfbid) in ctx.fwd2pgf_block
    pgfb = IRTools.block(pgfir, pgfbid)
    b = IRTools.block(ir, bid)
    pgfblock!(b, pgfb, ctx)
  end
  return pgfir
end

#analagous to invertir
function makePGFir(f::Type{F}, t::Type{T}) where {F, T}
  fwdir = Mjolnir.trace(Mjolnir.Defaults(), F, t.parameters...)
  IRTools.explicitbranch!(fwdir)  # IR-transforms assumes no implicit branching
  fwdir |> IRTools.expand! |> IRTools.explicitbranch!
  pgfir = pgf(fwdir)
end


makePGFir(f::Function, types::NTuple{N, DataType}) where {N} = 
  makePGFir(typeof(f), Base.to_tuple_type(types))

function pgfapplytransform(f::Type{F}, t::Type{T}) where {F, T}
  pgfir = makePGFir(f, t) |> IRTools.renumber
  Core.print("ok")
  Core.print(pgfir)
  Core.print("done!")

  # Finalize
  # zt - I wrote this (I think) but I'm not sure what they do?
  dummy() = return
  argnames_ = [Symbol("#self#"), :f, :t, :arg]
  ci = code_lowered(dummy, Tuple{})[1]
  ci.slotnames = [argnames_...]
  return update!(ci, pgfir)
end

@generated function pgfapply(f, t::Type{T}, arg) where T
  return pgfapplytransform(f, T)
end

function pgfapply(f, types::NTuple{N, DataType}, arg) where N
  pgfapply(f, Base.to_tuple_type(types), arg)
end


