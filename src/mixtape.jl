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
    pgfir = ParametricInversion.makePGFir(forward, argtypes)
    ci = IRTools.Inner.build_codeinfo(pgfir)
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
    invir = ParametricInversion.invertir(forward, argtypes)
    #ci = IRTools.Inner.build_codeinfo(invir)
    IRTools.Inner.update!(src, invir)
    display(src)
    display(src.pure)
    return src
end

#function preopt!(mix::InvMix, ir)
#    display(ir)
#    return ir
#end
#
#function postopt!(mix::InvMix, ir)
#    return ir
#end

Mixtape.@load_call_interface()

while true
    arg = 3
    invarg = foo(arg)

    thetas = call(PgfMix(), pgf, foo, arg)

    out = call(InvMix(), invert, foo, Int64, invarg, thetas)
    println(out)
end

#display(args)

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

