invertapply(::typeof(+), t::Type{Tuple{Float64, Float64}}, y, φ) = (v = ℝ(φ); (y - v, v))
invertapply(::typeof(+), t::Type{Tuple{Int64, Int64}}, y, φ) = (v = ℤ(φ); (y - v, v))
invertapply(::typeof(+), t::Type{Tuple{T, T}}, y, φ) where T = (v = ℝ(φ); (y - v, v))

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

function invertapply(::typeof(getindex), 
      types::Type{Tuple{PIConstant{Tuple{Float64, Float64, Float64}}, PIConstant{Int64}}}, 
      constants,
      y, 
      φ) where T
  constants[1].value[constants[2].value] = y
  (constants[1].value, constants[2].value)
end

function invertapply(::typeof(getindex), 
  types::Type{Tuple{PIConstant{Tuple{Float64, Float64, Float64}}, Int64}},
  constants,
  y, 
  φ) where T
  index = rand(1:3)
  constants[1].value[index] = y
  (constants[1].value, index)
end

function invertapply(::typeof(getindex), 
  types::Type{Tuple{Tuple{Float64, Float64, Float64}, PIConstant{Int64}}},
  constants,
  y, 
  φ) where T
  newtuple = (ℝ(φ), ℝ(φ), ℝ(φ))
  newtuple[constants[1].value] = y
  (newtuple, constants[1].value)
end

function invertapply(::typeof(getindex), 
  types::Type{Tuple{Tuple{Float64, Float64, Float64}, PIConstant{Int64}}},
  y, 
  φ) where T
  newtuple = (ℝ(φ), ℝ(φ), ℝ(φ))
  index = rand(1:3)
  newtuple[index] = y
  (newtuple, index)
end

# TODO: likely wrong?
invertapply(::typeof(tuple), types::Type{Tuple{Float64, Float64}}, y, φ) = y

### TODO:
# Handle multiple arguments like :+(%2, %3, %4, %5) (all with potentially different types)
# Handle inverse integer multiplication and division: factoring problems
# Define more primitives as needed
