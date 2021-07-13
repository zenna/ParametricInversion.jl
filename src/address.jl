methodid(args...) = hash(args)
methodid(ir::IR) = methodid(IRTools.argtypes(ir)...)

const MethodId = UInt

"Location in trace"
struct Loc{V}
  mthdid::MethodId
  statement::V
end