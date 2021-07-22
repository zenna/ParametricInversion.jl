# ParametricInversion.jl

Parametric Inversion is a library for inverting Julia programs.

## Quick Start

```julia
using ParametricInversion
f(x, y, z) = x + y * z
x_, y_, z_ = rand(3)
output = f(x_, y_, z_)
params = rand(2)
(x__, y__, z__) = invertinvoke(f, Tuple{Float64, Float64, Float64}, output, params)
f(x__, y__, z__)
```

## Index
```@index
```

```@autodocs
Modules = [ParametricInversion]
```