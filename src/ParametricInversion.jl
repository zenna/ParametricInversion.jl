"Julia in reverse: Parametric Inversion in pure Julia"
module ParametricInversion

using InteractiveUtils
using IRTools
using MacroTools
using Spec

using IRTools: Statement, varargs!, insertafter!, xcall, var, IR, Block, Branch, blocks, arguments
using IRTools.Inner: Variable 
using IRTools
using IRTools: varargs!, inlineable!, pis!, slots!, IR, var, xcall
using IRTools.Inner: argnames!, update!, argument!

using Mjolnir

export invertapply

include("util.jl")
using .Util

include("cfg.jl")
include("duplify.jl")
include("invert.jl")
include("param.jl")
include("primitives.jl")
include("passes.jl")
include("tagtraits.jl")


end