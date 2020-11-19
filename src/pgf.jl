export inverseparameters

"""

Parameters that can be used to invert to `x` from `y`
`parameters(f, types, args...)`

Produces parameters `θ` such that:

`inverseparameters(f, types, f(args...), θ) == args`

These parameters can be used for learning.
"""
function inverseparameters end