module Interpreter

export interpret
abstract type Node end

struct Add <: Node end
struct Sub <: Node end
struct Div <: Node end
struct Mul <: Node end

Base.show(io::IO, ::Add) = print(io, "+ₛ")
Base.show(io::IO, ::Sub) = print(io, "-ₛ")
Base.show(io::IO, ::Div) = print(io, "/ₛ")
Base.show(io::IO, ::Mul) = print(io, "*ₛ")

# const Value = Union{Term, Float64}

struct Term
  head::Node
  x::Union{Term, Float64}
  y::Union{Term, Float64}
end

a +ₛ b = Term(Add(), a, b)
a -ₛ b = Term(Sub(), a, b)
a *ₛ b = Term(Mul(), a, b)
a /ₛ b = Term(Div(), a, b)

Base.show(io::IO, term::Term) = print(io, term.x, " ", term.head, " ", term.y)

function interpret(t::Term)
  if t.head == Add()
    return interpret(t.x) + interpret(t.y)
  elseif t.head == Sub()
    return interpret(t.x) - interpret(t.y)
  elseif t.head == Div()
    return interpret(t.x) / interpret(t.y)
  elseif t.head == Mul()
    return interpret(t.x) * interpret(t.y)
  end
end

interpret(t::Float64) = t

function test()
  @show term = 15.3 *ₛ 12.2 +ₛ 41.8 /ₛ 5.2
  interpret(term)
end

end