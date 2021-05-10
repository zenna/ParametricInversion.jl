using ParametricInversion
using IRTools
using Mixtape
using CodeInfoTools
using CodeInfoTools: var, get_slot, walk, verify

# This is just a fallback stub. We intercept this in inference.
pgf(f, arg)  = nothing

@ctx (false, false, false) struct PgfMix end

# Allow the transform on our Target module.
allow(ctx::PgfMix, fn::typeof(pgf), args...) = true

function transform(mix::PgfMix, src, sig)
    if !(sig[2] <: Function) || 
        sig[2] === Core.IntrinsicFunction
        return src
    end # If target is not a function, just return src.
    b = CodeInfoTools.Builder(src)
    forward = sig[2].instance
    argtypes = sig[3 : end]
    println("fwd, argtypes:")
    println(forward)
    println(argtypes)
    pgfir = ParametricInversion.makePGFir(forward, argtypes)
    # println("pgfir: ", pgfir)
    src = IRTools.Inner.build_codeinfo(pgfir)
    # IRTools.Inner.update!(src, pgfir)
    # isempty(src.linetable) && 
    #   push!(src.linetable, Core.LineInfoNode(@__MODULE__, src.parent, :something, 0, 0))
    # Core.Compiler.validate_code(src)

    println("Resultant IR for $(sig):")
    return src
end

function foo(x)
    return x + 5
end

function complex(x)
  if x > 100
    x = x * x
  else
    y = x + 1
    x = x * y
  end
  x
end

function mid(x)
  if x > 100
    return x
  else 
    return x * x
  end
end


# This is just a fallback stub. We intercept this in inference.
invert(f, types, invarg, thetas) = nothing

@ctx (false, false, false) struct InvMix  end

# Allow the transform on our Target module.
allow(ctx::InvMix, fn::typeof(invert), args...) = true

function transform(mix::InvMix, src, sig)
    if !(sig[2] <: Function) || 
        sig[2] === Core.IntrinsicFunction
        return src
    end # If target is not a function, just return src.
    b = CodeInfoTools.Builder(src)
    forward = sig[2].instance
    argtypes = sig[3:end-2]
    println("generating invir")
    println("fwd, argtypes:")
    println(forward)
    println(argtypes)
    invir = ParametricInversion.invertir(forward, argtypes)
    # println("done w invir: ", invir)
    IRTools.Inner.update!(src, invir)
    isempty(src.linetable) && 
      push!(src.linetable, Core.LineInfoNode(@__MODULE__, src.parent, :something, 0, 0))
    Core.Compiler.validate_code(src)

    println("Resultant IR for $(sig):")
    println(src)
    verify(src)
    return src
end


import Mixtape: preopt!, postopt!
# preopt!(ctx::InvMix, ir) = (display(ir); ir)
# postopt!(ctx::InvMix, ir) = (display(ir); ir)

arg = 1
f = complex
invarg = f(arg)

Mixtape.@load_call_interface()
thetas = call(PgfMix(), pgf, f, arg)
display(thetas)


outargs = call(InvMix(), invert, f, arg, invarg, thetas)
println("output from inv: ", outargs, ", input to forward: ", arg)