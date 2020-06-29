module SATModel

# const Name = Symbol

# struct Atom
#   name::Name
# end

# struct NotLit
#   name::Name
# end

# const Literal = Union{Var, NotLit}

# struct Clause
#   lits::Set{Literal}
# end

# Clause(lits::Literal...) = Clause(Set{Literal}(lits))
# atoms(clause::Clause) = map(atom, clause.lits)

# struct CNF
#   clauses::Vector{Clause}
# end

# CNF(clause::Clause...) = CNF([clause...])
# atoms(cnf::CNF) = union(map(atoms, cnf.clauses))

# "Generate a function that evaluates whether `cnf` formula is true"
# function genfunc(cnf)
#   atoms(cnf)

# end

# Base.:!(v::Var) = NotVar(v.name)
# Base.:!(v::NotVar) = Var(v.name)

# ## Example

# function test()
#   A = Var(:A)
#   B = Var(:B)
#   C = Var(:C)
#   D = Var(:D)
#   E = Var(:E)
#   F = Var(:F)
#   c1 = Clause(A, !B, !C)
#   c2 = Clause(!D, E, F)
#   cnf = CNF(c1, c2)
# end

A ∧ B = A & B
A ∨ B = A | B

function ex1(A, B, C, D, E, F)
  (A ∨ !B ∨ !C) ∧ (!D ∨ E ∨ F)
end

end # module
