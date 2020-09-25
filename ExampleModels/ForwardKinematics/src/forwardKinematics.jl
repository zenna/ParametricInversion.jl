module ForwardKinematics

struct Point
    x::Float64
    y::Float64
end

# angles is an array of angles, in order from base to end, in radians. 
# lengths is an array of segment lengths, in order from base to end, in any (consistent) unit.
# returns Point(x, y) of final segment. 
# function forwardKinematics(angles::Array{Number}, lengths::Array{Number})
function forwardKinematics(angles, lengths)
    @assert (size(angles, 1) == size(lengths, 1)) "unequal parameter sizes"
    x = 0.0
    y = 0.0
    angleSum = 0.0
    for i = 1:size(angles, 1)
        angleSum += angles[i]
        x += lengths[i] * cos(angleSum)
        y += lengths[i] * sin(angleSum)
    end
    Point(x, y)
end

#=
# Simple test
println(forwardKinematics([3.1415], [1.0]))

# Fails due to unequal sizes
println(forwardKinematics([3.1415], [1.0, 2.0]))

# More complex test
println(forwardKinematics([0.4, 1.0, 2.0, 0.8, 0.0], [1.0, 2.0, 0.5, 2.0, 1.0]))
=#

end # module

