module Arithmetic
export evaluate, Constant, BinaryOp, ADD, SUB, MUL, DIV

abstract type Expression end

struct Constant{T} <: Expression
  value::T
end

@enum Op begin
  ADD = 1
  SUB = 2
  MUL = 3
  DIV = 4
end

struct BinaryOp{T1, T2} <: Expression
  left::T1
  op::Op
  right::T2
end

evaluate(expr::Constant) = expr.value

function evaluate(expr::BinaryOp)
  left_val = evaluate(expr.left)
  right_val = evaluate(expr.right)
  if expr.op == ADD
    return left_val + right_val
  elseif expr.op == SUB
    return left_val - right_val
  elseif expr.op == MUL
    return left_val * right_val
  elseif expr.op == DIV
    return left_val / right_val
  else 
    throw(error("Unknown op while evaluating BinaryOp"))
  end
end

end # module