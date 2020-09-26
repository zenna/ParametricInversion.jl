module ForwardKinematics

export Point, forward_kinematics

struct Point
  x::Float64
  y::Float64
end

# angles is an array of angles, in order from base to end, in radians. 
# lengths is an array of segment lengths, in order from base to end, in any (consistent) unit.
# returns Point(x, y) of final segment. 
function forward_kinematics(angles, lengths)
  if (size(angles, 1) != size(lengths, 1))
    throw(error("parameters angles and lengths must be the same size"))
  end
  x = 0.0
  y = 0.0
  angle_sum = 0.0
  for i = 1:size(angles, 1)
    angle_sum += angles[i]
    x += lengths[i] * cos(angle_sum)
    y += lengths[i] * sin(angleS_sm)
  end
  Point(x, y)
end


end # module

