using IRTools: blocks, returnvalue, branches, isreturn, predecessors

isvar(v) = typeof(v) == Variable

# zt -- this is far too long for what it does
function returnvars(b)
  if isreturn(b)
    ret = returnvalue(b)
    if ret isa Variable
      return [ret]
    else
      return Variable[]
    end
  else
    return Variable[]
  end
end

"Vars that are used in branching in block `b`"
branchvars(b) =
  reduce(vcat, [filter(isvar, [br.args; br.condition]) for br in  branches(b)], init = Variable[])

"vars used in statements of `b`"
stmts(b) = 
  reduce(vcat, [filter(isvar, b[v].expr.args) for v in keys(b)], init = Variable[])

"vars used in some form by block `b`"
usedvars(b) = stmts(b) ∪ branchvars(b) ∪ returnvars(b)

"Denotes that `old` was substituted for `new`"
struct Sub
  old::Variable
  new::Variable
end

"All"
branchpreds(block) =
  filter(br -> br.block == block, branches(predecessors(block)))

"""
Removes implicit use of variable
"""
function passvars!(ir)
  blocks_ = Set{Block}(blocks(ir)) ## zt: do we want to be putting ir into 
  Subs = []
  while !isempty(blocks_)
    println("Blocks ", [b.id for b in blocks_])
    b = pop!(blocks_)
    println("Popping block ", b.id)
    producedvars = arguments(b) ∪ keys(b)
    usedvars = stmts(b) ∪ branchvars(b) ∪ returnvars(b)
    dangling = setdiff(usedvars, producedvars)
    @show dangling
    if !isempty(dangling)
      for v in dangling
        arg = argument!(b)   # add th enecessary inputs
        # push!(subs, Sub(old, new))
        # zt -- doing multiple passes, could do more efficiently with one
        IRTools.prewalk!(b) do x
          if x isa Variable && x == v 
            arg
          else
            x
          end
        end
      end
      for pa in predecessors(b)          
        # For each block which branches to `b`, need to update the branch poins
        for br in branches(pa)
          if br.block == b.id
            offset = length(br.args) - length(dangling)
            @show dangling
            @show br.args
            for i = 1:length(dangling)
              br.args[i + offset] = dangling[i]
            end
            @assert !any(isnothing, br.args)
          end
        end
        println("Add block ", pa.id)
        push!(blocks_, pa)    # Add to queue (since we've updated it and it may now have dangling vars)
      end
    end
    display(ir)
    println("\n")
  end
  ir
end