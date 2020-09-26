using ForwardKinematics

# Simple test
println(forwardKinematics([3.1415], [1.0]))

# Fails due to unequal sizes
println(forwardKinematics([3.1415], [1.0, 2.0]))

# More complex test
println(forwardKinematics([0.4, 1.0, 2.0, 0.8, 0.0], [1.0, 2.0, 0.5, 2.0, 1.0]))