export cycle, cycleir, @cycle, @cycleir

# zt - Fixme this is type unstable
"`cycle(f, args...)` yields `xs_` such `f(xs_...) == f(args...)``"
cycle(φ, f, args...) =
  invertapply(f, Base.typesof(args...), f(args...), φ)

cycleir(f, args...) =
  invertir(typeof(f), Base.typesof(args...))

cycle(f, args...) = 
  cycle(defθ(), f, args...)

function cyclem(ex)
  if IRTools.isexpr(ex, :call)
    f, args = ex.args[1], ex.args[2:end]
  elseif IRTools.isexpr(ex, :do)
    f, args = ex.args[1].args[1], vcat(ex.args[2], ex.args[1].args[2:end])
  else
    error("@code_ir f(args...)")
  end
  esc(:(cycle(ParametricInversion.defθ(), $f, $args...)))
end

function cycleirm(ex)
  if IRTools.isexpr(ex, :call)
    f, args = ex.args[1], ex.args[2:end]
  elseif IRTools.isexpr(ex, :do)
    f, args = ex.args[1].args[1], vcat(ex.args[2], ex.args[1].args[2:end])
  else
    error("@code_ir f(args...)")
  end
  esc(:(cycleir($f, $args...)))
end

macro cycle(ex)
  cyclem(ex)
end

macro cycleir(ex)
  cycleirm(ex)
end