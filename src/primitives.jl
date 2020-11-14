invertapply(::typeof(+), t::Type{Tuple{Float64, Float64}}, y, φ) = (v = ℝ(φ); (y - v, v))
invertapply(::typeof(+), t::Type{Tuple{Int64, Int64}}, y, φ) = (v = ℤ(φ); (y - v, v))
invertapply(::typeof(+), t::Type{Tuple{T, T}}, y, φ) where T = (v = ℝ(φ); (y - v, v))

function invertapply(::typeof(+), t::Type{Tuple{PIConstant, Float64}}, y, φ) 
  c = constants[1].value
  (c, y-c)
end

invertapply(::typeof(-), t::Type{Tuple{Int64, Int64}}, y, φ) = (v = ℤ(φ); (y + v, v))
invertapply(::typeof(-), t::Type{Tuple{Float64, Float64}}, y, φ) = (v = ℝ(φ); (y + v, v))
invertapply(::typeof(-), types::Type{Tuple{T, T}}, y, φ) where T = (v = ℝ(φ); (y + v, v))

function invertapply(::typeof(*), t::Type{Tuple{Float64, Float64}}, y, φ)
  b = 𝔹(φ[2])
  v = ℝ(φ[1])
  b ? (y/v, v) : (v, y/v)
end

function invertapply(::typeof(*), t::Type{Tuple{Float64, PIConstant{T}}}, constants, y, φ) where T
  c = constants[1].value
  (y/c, c)
end

function invertapply(::typeof(*), t::Type{Tuple{T, T}}, y, φ) where T
  b = 𝔹(φ[2])
  v = ℝ(φ[1])
  b ? (y/v, v) : (v, y/v)
end

invertapply(::typeof(/), types::Type{Tuple{T, T}}, y, φ) where T = (y*ℝ(φ), ℝ(φ))

invertapply(::typeof(cos), types::Type{Float64}, y, φ) = (v = ℤ(φ); 2*pi*ceil(v/2) + (-1)^v * acos(y))

invertapply(::typeof(sin), types::Type{Float64}, y, φ) = (v = ℤ(φ); pi*v + (-1)^v * asin(y))

function invertapply(::typeof(<=), types::Type{Tuple{T, T}}, y, φ) where T 
 theta1 = ℝ(φ)
 theta2 = abs(ℝ(φ))
 y ? (theta1, theta1 + theta2) : (theta1, theta1 - theta2)
end

function invertapply(::typeof(>=), types::Type{Tuple{T, T}}, y, φ) where T 
  theta1 = ℝ(φ)
  theta2 = abs(ℝ(φ))
  y ? (theta1, theta1 - theta2) : (theta1, theta1 + theta2)
 end

 function invertapply(::typeof(==), types::Type{Tuple{T, T}}, y, φ) where T 
  theta1 = ℝ(φ)
  theta2 = ℝ(φ)
  y ? (theta1, theta1) : (theta1, theta1 + theta2)
 end

### TODO:
# Handle multiple arguments like :+(%2, %3, %4, %5) (all with potentially different types)
# Handle inverse integer multiplication and division: factoring problems
# Define more primitives as needed
