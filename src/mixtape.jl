using ParametricInversion
using IRTools
using Mixtape
using CodeInfoTools
using CodeInfoTools: var, get_slot, walk

# This is just a fallback stub. We intercept this in inference.
pgf(f, arg)  = nothing

@ctx (false, false, false) struct PgfMix  end

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
    ci = IRTools.Inner.build_codeinfo(pgfir)

    println("Resultant IR for $(sig):")
    return ci
end

function foo(x)
    return x + 5
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
    println("done w invir: ", invir)
    ci = IRTools.Inner.build_codeinfo(invir)

    println("Resultant IR for $(sig):")
    return ci
end

arg = 3
invarg = foo(arg)

Mixtape.@load_call_interface()
thetas = call(PgfMix(), pgf, foo, arg)
display(thetas)

Mixtape.@load_call_interface()
args = call(InvMix(), invert, foo, Int64, invarg, thetas)
display(args)

# using Mixtape
# using CodeInfoTools
# using CodeInfoTools: var, get_slot, walk, CodeInfo

# # This is just a fallback stub. We intercept this in inference.
# invert(ret, f, args...)  = f(args...)

# @ctx (false, false, false) struct Mix  end

# # Allow the transform on our Target module.
# allow(ctx::Mix, fn::typeof(invert), args...) = true

# function transform(mix::Mix, src, sig)
#   Core.println("here")
#   if !(sig[3] <: Function) || 
#       sig[3] === Core.IntrinsicFunction
#       return src
#   end # If target is not a function, just return b.
#   forward = sig[3].instance
#   argtypes = sig[4 : end]
#   forward = Mixtape._code_info(forward, Tuple{argtypes...})
  
#   return src
# end

# function foo(x)
#   return x + 5
# end

# Mixtape.@load_call_interface()
# ret = call(Mix(), invert, 10, foo, 5)
# display(ret)