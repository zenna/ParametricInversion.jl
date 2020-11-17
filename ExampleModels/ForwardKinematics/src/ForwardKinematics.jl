module ForwardKinematics

export Point, forward_kinematics

struct Point
  x::Float64
  y::Float64
end

# angles is an array of angles, in order from base to end, in radians. 
# lengths is an array of segment lengths, in order from base to end, in any (consistent) unit.
# returns Point(x, y) of final segment. 
function forward_kinematics(angles, lengths, len)
  x = 0.0
  y = 0.0
  angle_sum = 0.0
  for i = 1:len
    angle_sum += angles[i]
    x += lengths[i] * cos(angle_sum)
    y += lengths[i] * sin(angle_sum)
  end
  (x, y)
end

function fk_2(angles, lengths)
  x = 0.0
  y = 0.0
  angle_sum = 0.0
  for i = 1:3
    angle_sum += angles[i]
    x += lengths[i] * cos(angle_sum)
    y += lengths[i] * sin(angle_sum)
  end
  (x, y)
end

end # module


