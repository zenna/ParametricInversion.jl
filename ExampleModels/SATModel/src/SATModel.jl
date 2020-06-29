module SATModel

greet() = print("Hello World!")

struct Var
end

struct Clause
  
end

struct CNF
  clauses::Vector{Clause}
end

"Generate a function that evaluates whether `cnf` formula is true"
function genfunc(cnf)
end

A = Var()
B = Var()
C = Var()

# A ∧ B ∨ C

end # module
