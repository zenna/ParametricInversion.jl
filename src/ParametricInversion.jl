"Julia in reverse: Parametric Inversion in pure Julia"
module ParametricInversion

using Spec

using IRTools: Statement, varargs!, insertafter!, xcall, var, IR, Block, Branch, blocks, arguments
using IRTools.Inner: Variable 
import IRTools
using IRTools: varargs!, inlineable!, pis!, slots!, IR, var, xcall
using IRTools.Inner: argnames!, update!, argument!

using Mjolnir

export invertapply

include("util.jl")
using .Util

include("irutil.jl")
include("address.jl")

include("cfg.jl")
include("duplify.jl")
include("invert.jl")
include("cycle.jl")

include("param.jl")
include("var.jl")

include("primitives.jl")
include("passes.jl")
include("traits.jl")
include("choose.jl")
include("pgf.jl")



end