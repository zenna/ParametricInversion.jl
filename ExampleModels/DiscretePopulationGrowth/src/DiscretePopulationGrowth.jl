module DiscretePopulationGrowth

using UnicodePlots

"Next time step of lohistic model"
next(xt, b) = b * (1 - xt)xt

function sim(x0, b, n)
  x = x0
  xs = [x]
  for i = 1:n
    x = next(x, b)
    push!(xs, x)
  end
  xs
end

function test()
  lineplot(sim(0.1, 2.2, 500))  
end

end # module
