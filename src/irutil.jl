const BlockId = Int
const BranchId = Int

# "Mapping from variable to set of variables it corresponds to in inverse"
# d[(v1, id) = v2] means that v1 in ir corresponds to v2 on invblock id
const VarMap = Dict{Tuple{Variable, BlockId}, Set{Variable}}

# A Branch on a Block -- need this because branches on different blocks share same id
const BranchBlock = NamedTuple{(:branch, :block), Tuple{BranchId, BlockId}}

"add `v` to `vm[k]`"
function add!(vm::VarMap, v::Variable, bid::BlockId, v2::Variable)
  k = (v, bid)
  if k in keys(vm)
    push!(vm[k], v2)
  else
    vm[k] = Set([v2])
  end
end
@post [@cap(vm)[k] ; v] == vm[k]

unwrap(x::Type) = x
unwrap(x::Mjolnir.Const{T}) where {T} = T

"Mapping from variables (including arguments) to inferred types"
function vartypes(ir::IR)
  vtypes = Dict{Variable, Type}()
  for b in blocks(ir)
    for (v, t) in zip(arguments(b), unwrap.(argtypes(b)))
      if t <: Type{<:Any}
        # Changes from Type{Int64} to just Int64, for example
        t = t.parameters[1]  #dm: hack probably
      end
      vtypes[v] = t
    end
  end
  for v in keys(ir)
    vtypes[v] = ir[v].type
  end
  vtypes
end

"Argument types of statement `stmt` according to vartypes `vtypes`"
function stmtargtypes(stmt::Statement, vtypes)
  t = map(stmt.expr.args[2:end]) do arg
    if isvar(arg)
      vtypes[arg]
    else
      typeof(arg)
    end    
  end
  Tuple{t...}
end

#zt - move to helpers
"What branchblocks are incoming into block b"
function incomingbranches(b)
  bs = BranchBlock[]
  for pa in IRTools.predecessors(b)
    for (brid, br) in enumerate(branches(pa))
      if br.block == b.id
        push!(bs, (branch = brid, block = pa.id))
      end
    end
  end
  bs
end

"Arguments of a statement"
fargs(b::Block) =
  length(arguments(b)) > 1 ? arguments(b)[2:end] : []

"Head of expression defined by statement"
head(stmt::Statement) =  stmt.expr.args[1]

"Each statement of block `b` and associated Variable"
statements(b::Block) = collect((var = k, stmt = b[k]) for k in keys(b))
