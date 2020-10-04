using ForwardKinematics
using Test

floatEquals(x, y, eps) = abs(x - y) <= eps

# Simple test
point = forward_kinematics([pi], [1.0])
@test floatEquals(point.x, -1, 0.00001)
@test floatEquals(point.y,  0, 0.00001)

# Exception due to unequal sizes
try
  forward_kinematics([3.1415], [1.0, 2.0])
  @test false
catch err
end

# More complex test
point = forward_kinematics([0.4, 1.0, 2.0, 0.8, 0.0], [1.0, 2.0, 0.5, 2.0, 1.0])
@test floatEquals(point.x, -0.693186, 0.000001)
@test floatEquals(point.y, -0.382180, 0.000001)
