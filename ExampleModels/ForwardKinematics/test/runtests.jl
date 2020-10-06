using ForwardKinematics
using Test

@testset "Simple FK" begin 
  point = forward_kinematics([pi], [1.0])
  @test point.x ≈ -1 atol=0.00001
  @test point.y ≈ 0 atol=0.00001
end

@testset "Exception due to unequal argument sizes" begin 
  try
    forward_kinematics([3.1415], [1.0, 2.0])
    @test false
  catch err
  end
end

@testset "Complex FK" begin
  point = forward_kinematics([0.4, 1.0, 2.0, 0.8, 0.0], [1.0, 2.0, 0.5, 2.0, 1.0])
  @test point.x ≈ -0.693186 atol=0.00001
  @test point.y ≈ -0.382180 atol=0.00001
end