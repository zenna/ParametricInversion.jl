export choose

"""
`choose(ctx, loc, f, types, target, known. θ)`

Parametrically choose a value for variables in relation defined by method
`f(::types..)`, given information about other values in relation.

# Arguments
- `f(::types...)` - method to choose from
- `loc`    - Location
- `target` - which axis we wish to choose onto
- `given`  - what is given/known about values of the relation (e.g. value of input)
- `θ`      - Parameter values which determine which element to choose
"""
function choose end