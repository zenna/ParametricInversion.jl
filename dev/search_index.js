var documenterSearchIndex = {"docs":
[{"location":"relation/#Parametric-Relational-Programming","page":"relation","title":"Parametric Relational Programming","text":"","category":"section"},{"location":"relation/","page":"relation","title":"relation","text":"Both the conventional forward execution  as well as parametric inversion of a program can be viewed as two extremes in a broader relational space.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"To appreciate this, let's first establish some of the basic properties of relations.","category":"page"},{"location":"relation/#Relations","page":"relation","title":"Relations","text":"","category":"section"},{"location":"relation/","page":"relation","title":"relation","text":"<!– A relation R is a set of tuples. –> A relation over sets X_1 dots X_n is a subset of the Cartesian product X_1 times cdots times X_n; that is, it is a set of n-tuples (x_1 dots x_n) consisting of elements x_i in X_i.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"<!– These sets can be infinite; the finitaryness of a finitary relation means that the number of dimensions is finite, i.e., n in mathbbN. –>","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"The non-negative integer n giving the number of \"places\" in the relation is called the arity, adicity or degree of the relation. A relation with n \"places\" is variously called an n-ary relation. Relations with a finite number of places are called finitary relations.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"For instance, addition is a relation, which we will call R_+:","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"$","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"{(0, 0, 0), (1, 0, 1), (1, 1, 0), (2, 1, 1) \\dots} $","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"where the first, second and third element of each tuple represent the variables z, a, and b in the equation z = a + b.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Another way to represent a relation is as a table.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"z a b\n5 2 3\n4 2 2\n4 3 1","category":"page"},{"location":"relation/#Reasoning-Using-(Functional)-Relations","page":"relation","title":"Reasoning Using (Functional) Relations","text":"","category":"section"},{"location":"relation/","page":"relation","title":"relation","text":"Suppose I tell you that a = 2 and b = 3, and I want the value of z.  We can provide an answer to this question by applying a restricting the relation to select only those values that are consistent with the given information, yielding:","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"z a b\n5 2 3\n~~4~~ ~~2~~ ~~2~~\n~~4~~ ~~3~~ ~~1~~","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Naturally, this operation is called a selection, and performed by an operation called sigma (\"s\" in sigma corresponds to \"s\" in selection).","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"The selection function sigma  Phi times mathcalR to mathcalR filters out all elements of a relation R in mathcalR (the set of relations) which are inconsistent with a predicate varphi in Phi.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"In this example, the selection predicate is varphi(x) = x_a = 2 land x_b = 3. Applying selection operator sigma_varphi to R yields R_varphi = sigma_varphi(R_+) where R_varphi = x mid varphi(x) x in R_+.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"After selection, a single row remains. A relation with a single set is called a singeleton (R_varphi is the singleton set (5 2 3)).  The selection produces a singleton relation not just for varphi = x_a = 2 land x_b = 3, but forall values of a and b. In other words, given values for a and b, there is always a single value of z. In this case, we shall say R is functional on a b to z.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Definition: A relation R is functional on x_1 dots x_n to y_1 dots y_m  if and only if all of the following conditions hold: (i) for all x_1 x_2 dots x_n sigma_varphi(R) is a singleton relation where varphi = x_1 = x land x_2 = x_2 land cdots land x_n = x_n","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"We can see then that R_+ is functional on a b, on a b","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Why do functional relations matter? They matter because ","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Extract the Z axis","category":"page"},{"location":"relation/#Reasoning-Using-Non-Functional-Relations","page":"relation","title":"Reasoning Using Non-Functional Relations","text":"","category":"section"},{"location":"relation/","page":"relation","title":"relation","text":"Now suppose I tell you that z = 4 and I want the values of a and b. Applying the corresponding selection to R_+ yields a new relation:","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Z A B\n~~5~~ ~~2~~ ~~3~~\n4 2 2\n4 3 1","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"This time, after selection, infinitely many rows remain, two of which are shown here. The primary idea that parametric relational programming inherits from parametric inversion is to parametrically represent this set.  To do this, we introduce the concept of extending a relation with a parameter space. <!–  The relational perspective allows us to consider other things we might want to do with a relation than just compute the input given the output.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"There are a few things to note:","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"This relation is function on (A, B) -> (Z,) but not on (Z,) -> (A, B)\nAddition and subtraction are two sides of the same relation","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Functions are relations that have the property that for any input in the relation there is a single output.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"This property is important as it is a precondition for computing functions.  That is, using a programming language like Julia, we can define an algorithm which computes the output value of a function given the input value. –>","category":"page"},{"location":"relation/#Relational-Extension","page":"relation","title":"Relational Extension","text":"","category":"section"},{"location":"relation/","page":"relation","title":"relation","text":"An extension to a relation introduces a new place. To demonstrate, let us extend the addition relation with a new column theta:","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Z A B θ\n5 2 3 4\n4 2 2 1\n4 3 1 2","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"The purpose of an extension is to make the relational functional on all of its places.  Now:","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"R\nis functional on z theta to a b\nR\nis functional on a theta to z b\nR\nis functional on b theta to z a","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Definition: Formally, a relation R_theta is an extension to a R if and only if: (1) (2) ","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"[TODO soundness / completeness]","category":"page"},{"location":"relation/#The-Choose-Operator","page":"relation","title":"The Choose Operator","text":"","category":"section"},{"location":"relation/","page":"relation","title":"relation","text":"This sequence of four steps – extending a relation, selecting a subset of it, projecting into onto some axes and – are then a form of recipe. Here, we'll give this sequence a name","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"$","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"\\text{choose}{\\varphi, \\alpha} = \\text{project}\\alpha \\circ \\text{select}_\\varphi \\circ \\text{extend} =  \\pi \\circ \\sigma \\circ \\epsilon $","category":"page"},{"location":"relation/#Programs-as-Relations","page":"relation","title":"Programs as Relations","text":"","category":"section"},{"location":"relation/","page":"relation","title":"relation","text":"In reality, these relations are not represented explicitly as either sets or as tables.  Rather, they are represented as programs.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Let's start with a simple program.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"function f(a, b)\n  z = a * b + a\n  return z\nend","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"This program is a straight-line program in the sense that it uses no loops or any form of recursion. In addition it has no side effects, and hence it is a functional program.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"There are many different questions we might want to ask:","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Given values for a and b, what is the value of z\nGiven a value for z, provide a value for a and b\nGiven a value for a, provide a value for b and z\nGiven a value for b, provide a value for a and z","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"To answer these questions, we want to follow the approach layed about above.  Unfortuantely, is not represented as an explicit enumerable set or table, not least be because R is infinite, and could not be represented explicitly.","category":"page"},{"location":"relation/#Ordering","page":"relation","title":"Ordering","text":"","category":"section"},{"location":"relation/","page":"relation","title":"relation","text":"The approach we will take is to reoder f.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"First, let's see the program in SSA form:","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"function f(a, b)\n  v1 = a * b\n  z = v1 + a\n  return z\nend","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"The basic idea behind parametric relational programming is that there is a great deal of flexibility in the order in which we execute statements. In this example, we know the value of the output z and we want the inputs a and b.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Here's a possible two-step strategy:","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Strategy 1:","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Parametrically invert + to yield values for a and v1\nParametrically invert * to yield values for a and b","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"If we produced two different values for a in these steps then that is an inconsistency error.  That is, we chose \"wrong\" parameter values.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"But here's a better strategy that side steps this problem","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Strategy 2:","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Choose a value for a\nInvert + to yield values for v1 given the values for a and v2\nInvert * to yield a value for b given a","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"The inconsistency has been avoided, by  construction.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"We can think of these two strategies as different ways to order the computation.  Let's write them in a slightly more formal language.","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Strategy 1 (formal):","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Inputs: z","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"v_1 a leftarrow (+ z circ circ)\na b leftarrow (* v_1 circ circ)","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Strategy 2 (formal):","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Inputs: z","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"v_1 a leftarrow (+ z circ circ)\nb leftarrow (* v_1 a circ)","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Definition: An ordering of a procedure f [Whats a procedure?]. is a sequence (q_1 q_2 dots q_n) where each q_i = (R_i G_i P_i) is a tuple where R is [the name of?] a relation, and both G and P are sets of variables [Whats a variable?].","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"For any particular ordering, there are a number of important properties that we would like it to satisfy\"","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"Completeness.  Basically the variables used by each statement must be available, i.e. produced by a previosu variable or as an input\nvariable should only be produced once – not so simple, if we have an example\nSomething someting else","category":"page"},{"location":"relation/#Open-Questions","page":"relation","title":"Open Questions","text":"","category":"section"},{"location":"relation/","page":"relation","title":"relation","text":"Q: Should we be able to reorient to internal values?","category":"page"},{"location":"relation/","page":"relation","title":"relation","text":"– Can assume we start with some knowns, which are inputs. – What is a reorientation?  It","category":"page"},{"location":"#ParametricInversion.jl","page":"Home","title":"ParametricInversion.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Parametric Inversion is a library for inverting Julia programs.","category":"page"},{"location":"#Quick-Start","page":"Home","title":"Quick Start","text":"","category":"section"},{"location":"#Index","page":"Home","title":"Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ParametricInversion]","category":"page"},{"location":"#ParametricInversion.ParametricInversion","page":"Home","title":"ParametricInversion.ParametricInversion","text":"Julia in reverse: Parametric Inversion in pure Julia\n\n\n\n\n\n","category":"module"},{"location":"#ParametricInversion.Loc","page":"Home","title":"ParametricInversion.Loc","text":"Location in trace\n\n\n\n\n\n","category":"type"},{"location":"#ParametricInversion.PIConstant","page":"Home","title":"ParametricInversion.PIConstant","text":"Constant\n\n\n\n\n\n","category":"type"},{"location":"#ParametricInversion.Places","page":"Home","title":"ParametricInversion.Places","text":"Places refers to a subset of the axes (aka dimension, column, attributes) of relation\n\n\n\n\n\n","category":"type"},{"location":"#ParametricInversion.add!-Tuple{Dict{Tuple{IRTools.Inner.Variable, Int64}, Set{IRTools.Inner.Variable}}, IRTools.Inner.Variable, Int64, IRTools.Inner.Variable}","page":"Home","title":"ParametricInversion.add!","text":"add v to vm[k]\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.branchpreds-Tuple{Any}","page":"Home","title":"ParametricInversion.branchpreds","text":"All\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.branchvars-Tuple{Any}","page":"Home","title":"ParametricInversion.branchvars","text":"Vars that are used in branching in block b\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.choose","page":"Home","title":"ParametricInversion.choose","text":"choose(ctx, loc, f, types, target, known. θ)\n\nParametrically choose a value for variables in relation defined by method f(::types..), given information about other values in relation.\n\nArguments\n\nf(::types...) - method to choose from\nloc    - Location\ntarget - which axis we wish to choose onto\ngiven  - what is given/known about values of the relation (e.g. value of input)\nθ      - Parameter values which determine which element to choose\n\n\n\n\n\n","category":"function"},{"location":"#ParametricInversion.cycle-Tuple{Any, Any, Vararg{Any, N} where N}","page":"Home","title":"ParametricInversion.cycle","text":"cycle(f, args...) yields xs_ such f(xs_...) == f(args...)`\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.duplify!-Tuple{Any}","page":"Home","title":"ParametricInversion.duplify!","text":"Ensure there is single usage of a particular variable\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.enumplaces-Tuple{Any}","page":"Home","title":"ParametricInversion.enumplaces","text":"For statement of the form v1 = f(v2, v3, ..., vn) produces [v1, v2, ..., vn]\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.fargs-Tuple{IRTools.Inner.Block}","page":"Home","title":"ParametricInversion.fargs","text":"Arguments of a statement\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.head-Tuple{IRTools.Inner.Statement}","page":"Home","title":"ParametricInversion.head","text":"Head of expression defined by statement\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.incomingbranches-Tuple{Any}","page":"Home","title":"ParametricInversion.incomingbranches","text":"What branchblocks are incoming into block b\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.inverseparameters","page":"Home","title":"ParametricInversion.inverseparameters","text":"Parameters that can be used to invert to x from y parameters(f, types, args...)\n\nProduces parameters θ such that:\n\ninverseparameters(f, types, f(args...), θ) == args\n\nThese parameters can be used for learning.\n\n\n\n\n\n","category":"function"},{"location":"#ParametricInversion.invert!-Tuple{IRTools.Inner.Block, IRTools.Inner.Block, ParametricInversion.PIContext, Dict{IRTools.Inner.Variable, Any}}","page":"Home","title":"ParametricInversion.invert!","text":"invert block b, store result in invb, assume v ∈ knownvars is known\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.invert-Tuple{IRTools.Inner.IR}","page":"Home","title":"ParametricInversion.invert","text":"ir::IR that computes inverse inverse of ir\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.invertci-Union{Tuple{T}, Tuple{Any, Type{T}}} where T<:Tuple","page":"Home","title":"ParametricInversion.invertci","text":"Produce inverse ::CodeInfo\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.invertinvoke-Union{Tuple{T}, Tuple{Any, Type{T}, Any, Any}} where T<:Tuple","page":"Home","title":"ParametricInversion.invertinvoke","text":"invertinvoke(f, t::Type{<:Tuple}, z, θ)\n\nParametric inverse application of method f(::t...) to args with parameters θ\n\nInputs:\n\nf - function to invert t - Tuple of types which determines method of f to invert z - Input to inverse method θ - Parameter values\n\nReturns\n\n(a, b, c, ...) - tuple of values \n\nf(x, y, z) = x * y + z\nx, y, z = invertinvoke(f, Tuple{Float64, Float64, Float64}, 2.3, rand(3))\n@assert f(x, y, z) == 2.3\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.invertir-Union{Tuple{T}, Tuple{Any, Type{T}}} where T<:Tuple","page":"Home","title":"ParametricInversion.invertir","text":"invertir(f, t::Type{T})\n\nProduce inverse ast for method f(::T)\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.knownvars-Tuple{Any, Int64}","page":"Home","title":"ParametricInversion.knownvars","text":"When entering block at branchpoint brid, which variables are known?\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.locallyundefinedvars-Tuple{Any}","page":"Home","title":"ParametricInversion.locallyundefinedvars","text":"Variables that are used in block b but neither defined in b nor inputs to b\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.nused-Tuple{Any, IRTools.Inner.IR}","page":"Home","title":"ParametricInversion.nused","text":"Number of times var is used in block\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.nused-Tuple{Any, IRTools.Inner.Statement}","page":"Home","title":"ParametricInversion.nused","text":"Num times v is used in smt\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.passvars!-Tuple{Any}","page":"Home","title":"ParametricInversion.passvars!","text":"passvars!(ir)\n\nRemoves implicit use of variable. Updates ir such that if a block uses some variable v then v is an input to that block.\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.producedvars-Tuple{Any}","page":"Home","title":"ParametricInversion.producedvars","text":"Variables that are produced by b: inputs or lhs of statements\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.reversestatements!-Tuple{IRTools.Inner.Block, IRTools.Inner.Block, ParametricInversion.PIContext, Dict{IRTools.Inner.Variable, Any}}","page":"Home","title":"ParametricInversion.reversestatements!","text":"Undo each operation statement %a = f(%x, %y, %z) in b, add to invb\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.stmtargtypes-Tuple{IRTools.Inner.Statement, Any}","page":"Home","title":"ParametricInversion.stmtargtypes","text":"Argument types of statement stmt according to vartypes vtypes\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.stmts-Tuple{Any}","page":"Home","title":"ParametricInversion.stmts","text":"vars used in statements of b\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.usedvars-Tuple{Any}","page":"Home","title":"ParametricInversion.usedvars","text":"vars used in some form by block b\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.varreplace!-Tuple{Any, Any, Any}","page":"Home","title":"ParametricInversion.varreplace!","text":"Repalce all occurances of x with y variable v1 with variable v2 in block b\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.varstatements-Tuple{IRTools.Inner.Block}","page":"Home","title":"ParametricInversion.varstatements","text":"Each statement of block b and associated Variable\n\n\n\n\n\n","category":"method"},{"location":"#ParametricInversion.vartypes-Tuple{IRTools.Inner.IR}","page":"Home","title":"ParametricInversion.vartypes","text":"Mapping from variables (including arguments) to inferred types\n\n\n\n\n\n","category":"method"}]
}
