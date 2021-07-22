using ParametricInversion

function inverse_kinematics(point)
  input_t = Tuple{Float64, Float64}
  θ = rand(10)
  invertinvoke(forward_kinematics, Tuple{input_t, input_t}, point, θ)
end

function test_ik()
  angles = (rand(), rand(), rand())
  lengths = (rand(), rand(), rand())
  point = forward_kinematics(angles, lengths)
  inverse_kinematics(point)
end