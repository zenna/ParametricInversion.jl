using ParametricInversion
using IRTools

function f(x)
  if x > 100
    x = x * x
  else
    y = x + 1
    x = x * y
  end
  x
end

function simple(x)
  x+1
end

# println(ParametricInversion.invertir(typeof(f), Tuple{Float64}))

# pgfir = ParametricInversion.makePGFir(typeof(simple), Tuple{Int64})
# # pgfir = ParametricInversion.makePGFir(typeof(f), Tuple{Int64})
# pgfir = pgfir |> IRTools.ssa! |> IRTools.prune! |> IRTools.renumber
# println(pgfir)

# pgf = IRTools.func(pgfir)
# println(pgf(typeof(simple), 3))

println(pgfapply(simple, (Int64,), 3))
