# invdupl(x1) = x1
# invdupl(x1, x2) = x1
# invdupl(x1, x2, x3) = x1
# invdupl(x1, x2, x3, x4) = x1
# invdupl(x1, x2, x3, x4, x5) = x1

invdupl(xs...) = (@show(xs); first(xs))

dupl2(x) = (x, x)
dupl3(x) = (x, x, x)
dupl4(x) = (x, x, x, x)
dupl5(x) = (x, x, x, x, x)
dupl6(x) = (x, x, x, x, x, x)
dupl7(x) = (x, x, x, x, x, x, x)
duplen(x, n) = ((x for i = 1:n)...,)

"Num times `v` is used in `smt`"
nused(v, smt::Statement) = count(map((==)(v), smt.expr.args))

"Number of times `var` is used in block"
nused(v, ir::IR) = sum([nused(v, pair.second) for pair in values(ir)])

nreused(ir) = Dict(v => nused(v, ir) for v in keys(ir))

"Ensure there is single usage of a particular variable"
function duplify!(ir)
  # pr = IRTools.Pipe(ir)
  pr = ir
  nreused_ = nreused(ir)

  # Clotnes of variables to be duplicate
  dupls = Dict{Variable, Vector{Variable}}()
  
  # Insert duplications
  for (v, n) in nreused_
    if n >= 2
      @show v, n
      @show duplv = insertafter!(pr, v, xcall(ParametricInversion, :dupln, v, n))
      @show vs = [insertafter!(pr, duplv, xcall(:getindex, duplv, i)) for i = 1:n]
      dupls[v] = vs
    end
  end

  # Replace Variables
  @show dupls
  @show counts = Dict(k => 0 for (k, v) in nreused_ if v >= 2)
  function f(v::Variable)
    if v in keys(counts)
      # Ignore the first usage of it (which is _ = dupl(v))
      clone = counts[v] == 0 ? v : dupls[v][counts[v]]
      counts[v] += 1
      clone
    else
      v
    end
  end
  f(x) = x
  MacroTools.prewalk(f, ir)
end