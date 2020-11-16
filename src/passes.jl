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

"Variables that are produced by `b`: inputs or lhs of statements"
producedvars(b) = arguments(b) ∪ keys(b)

"Variables that are used in block `b` but neither defined in `b` nor inputs to `b`"
locallyundefinedvars(b) = setdiff(usedvars(b), producedvars(b))

"Repalce all occurances of `x` with `y` variable `v1` with variable `v2` in block `b`"
function varreplace!(b, v1, v2)
  IRTools.prewalk!(b) do x
    if x isa Variable && x == v1
      v2
    else
      x
    end
  end
end

"""
`passvars!(ir)`

Removes implicit use of variable.
Updates `ir` such that if a block uses some variable `v` then `v` is an input to that block.
"""
function passvars!(ir)
  blockidss_ = Set{Int}([b.id for b in IRTools.blocks(ir)]) ## zt: do we want to be putting ir into 
  m = Dict{Variable, Set{Variable}}()  # Mapping from vars to equivalence class
  while !isempty(blockidss_)
    bid = pop!(blockidss_)
    b = IRTools.block(ir, bid)
    undefvars = locallyundefinedvars(b)

    # Nothing to do if no undefined vars, skip
    if !isempty(undefvars)
      newargs = Variable[]
      for v in undefvars
        # Is `v` truly undefined (locally), or is it equal to one of the inputs
        res = findfirst(arg -> arg in keys(m) && v in m[arg], arguments(b))
        # If so : add a new argument 
        if isnothing(res)
          arg = argument!(b)      # add the enecessary inputs
          push!(newargs, v)
          # zt -- doing multiple passes, could do more efficiently with one
          varreplace!(b, v, arg)  # 
          push!(get!(m, arg, Set{Variable}()), v)
        else
          varreplace!(b, v, arguments(b)[res])
        end
      end

      isempty(newargs) && continue
      # If we have added new arguments we need to update all the branch points that lead here
      for pa in predecessors(b)          
        # For each block which branches to `b`, need to update the branch poins
        for br in branches(pa)
          if br.block == b.id
            offset = length(br.args) - length(newargs)
            for i = 1:length(newargs)
              br.args[i + offset] = newargs[i]
            end
            @assert !any(isnothing, br.args)
          end
        end
        push!(blockidss_, pa.id)    # Add to queue (since we've updated it and it may now have undefvars vars)
      end
    end
  end
  ir
end