module Arithmetic

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

function evaluate(expr::Constant)
    expr.value
end

function evaluate(expr::BinaryOp) 
    leftVal = evaluate(expr.left)
    rightVal = evaluate(expr.right)
    if expr.op == ADD
        return leftVal + rightVal
    elseif expr.op == SUB
        return leftVal - rightVal
    elseif expr.op == MUL
        return leftVal * rightVal
    elseif expr.op == DIV
        return leftVal / rightVal
    else 
        println("Unknown op while evaluating BinaryOp")
    end
end

#=

# Simple Test
# 4 
println(evaluate(Constant(4)))
# 1 * 3
println(evaluate(BinaryOp(Constant(1), MUL, Constant(3))))
# 2 + 4 / 4
println(evaluate(BinaryOp(Constant(2), ADD, BinaryOp(Constant(4), DIV, Constant(4)))))

=#

# function evaluate(expr::String)
#     evaluate(parse(expr))
# end

# Parsing code WIP

# function isOperator(c::Char) 
#     c == '+' || c == '-' || c == '*' || c == '/'
# end

# function precedence(op::String)
#     if op == "+" || op == "-"
#         return 0
#     elseif op == "*" || op == "/"
#         return 1
#     end
# end


# WIP: parsing tokens into AST
# function parse(input::String) 
#     function parseHelper(tokens, startIndex, endIndex)
#         for index = startIndex:endIndex
#     end

#     tokens = tokenize(input)
#     parseHelper(tokens, 1, size(tokens, 1))
# end

# function tokenize(input::String)
#     tokens = String[]
#     current = ""
#     for char in input
#         if isdigit(char)
#             current *= string(char)
#         elseif isOperator(char)
#             if current != ""
#                 push!(tokens, current)
#             end
#             push!(tokens, string(char))
#             current = ""
#         else # not number or operator, must be whitespace
#             if current != ""
#                 push!(tokens, current)
#             end
#             current = ""
#         end
        
#     end
#     push!(tokens, current)
#     return tokens
# end

end # module