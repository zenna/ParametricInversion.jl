module ParametricInversionEvaluation
using JuliaProgrammingPuzzles: typesig
import JuliaProgrammingPuzzles
using ParametricInversion
using Mjolnir
using Mjolnir: Basic, AType, Const, abstract

# Mjolnir.abstract(::Basic, ::AType{typeof(count)}, str, c) = (Core.print(str); Int)
"Find a string with 1000 'o's, 100 pairs of adjacent 'o's and 801 copies of 'ho'."
function study_2_sat(s::String)
  (count("o", s) == 1000) & (count("oo", s) == 100) & (count("ho", s) == 801)
end

# Mjolnir.abstract(::Basic, ::AType{typeof(count)}, str, c) = (@show str; Int)

test2() =  Mjolnir.trace(Mjolnir.Defaults(), typeof(study_2_sat), String)

export PISolver, evaluate_pi

struct PISolver end

inputtypes(sig::Type{Tuple{A, B}}) where {A, B} = Tuple{B}
inputtypes(sig::Type{Tuple{A, B, C}}) where {A, B, C} = Tuple{B, C}
inputtypes(sig::Type{Tuple{A, B, C, D}}) where {A, B, C, D} = Tuple{B, C, D}
inputtypes(sig::Type{Tuple{A, B, C, D, E}}) where {A, B, C, D, E} = Tuple{B, C, D, E}

function JuliaProgrammingPuzzles.solve(f, ::PISolver)
  # invert the program
  # execute with "true"
  θ = rand(5)
  invertinvoke(f, inputtypes(typesig(f)), true, θ)
end

evaluate_pi(; kwargs...) = JuliaProgrammingPuzzles.evaluate_many(PISolver(); kwargs...)

test() = invertinvoke(JuliaProgrammingPuzzles.simple_real_1, Tuple{Int, Int}, true, rand(3))

end # module