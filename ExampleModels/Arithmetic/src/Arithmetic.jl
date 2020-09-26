module Arithmetic
export evaluate, Constant, BinaryOp

abstract type Expression end

struct Constant <: Expression
  value::Number
end

@enum OP begin
  ADD = 1
  SUB = 2
  MUL = 3
  DIV = 4
end

struct BinaryOp <: Expression
  left::Expression
  op::OP
  right::Expression
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