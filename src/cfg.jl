struct CFGBlock
  incoming::Array{Tuple{Branch, Int64}}
  outgoing::Array{Branch}
end

struct CFG
  cfg::Array{CFGBlock}
  return_blocks::Array{Tuple{Branch, Int64}}
end

function build_cfg(ir::IR) 
  cfg = []
  for b in 1:size(ir.blocks, 1)
    push!(cfg, CFGBlock([], []))
  end
  return_blocks = []
  for b in 1:size(ir.blocks, 1)
    for branch in ir.blocks[b].branches
      if branch.block == 0
        push!(return_blocks, (branch, b))
        continue
      end
      push!(cfg[b].outgoing, branch)
      push!(cfg[branch.block].incoming, (branch, b))
    end
  end
  return CFG(cfg, return_blocks)
end

function build_fwdtypes(ir::IR)
  fwdtypes = Dict{IRTools.Variable, Type}()
  for b in 1:size(ir.blocks, 1)
    block = IRTools.block(ir, b)
    for i in 1:size(IRTools.arguments(block), 1)
      arg = IRTools.arguments(block)[i]
      argtype = IRTools.argtypes(block)[i]
      fwdtypes[arg] = argtype
    end
    for var in keys(block)
      stmt = block[var]
      fwdtypes[var] = stmt.type
    end
  end
  println(fwdtypes)
  fwdtypes
end
