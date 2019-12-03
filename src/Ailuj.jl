"Jula in reverse: Parametric Inversion in pure Julia"
module Ailuj

using InteractiveUtils
using IRTools
using MacroTools
using Spec

using IRTools: Statement, varargs!, insertafter!, xcall, var, IR, Block, blocks, arguments
using IRTools.Inner: Variable 
using IRTools
using IRTools: varargs!, inlineable!, pis!, slots!, IR, var, xcall
using IRTools.Inner: argnames!, update!, argument!

export invert
# using ZenUtils

include("duplify.jl")
include("invert.jl")
include("param.jl")
include("primitives.jl")


include("test.jl")
end # module
