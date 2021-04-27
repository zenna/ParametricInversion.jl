# Parametric Relational Programming 

Both the conventional forward execution  as well as parametric inversion of a program can be viewed as two extremes in a broader *relational* space.

To appreciate this, let's first establish some of the basic properties of relations.

## Relations
<!-- A relation $R$ is a set of tuples. -->
A relation over sets $X_1, \dots, X_n$ is a subset of the Cartesian product $X_1 \times \cdots \times X_n$; that is, it is a set of n-tuples $(x_1, \dots, x_n)$ consisting of elements $x_i$ in $X_i$.

<!-- These sets can be infinite; the finitaryness of a finitary relation means that the number of dimensions is finite, i.e., $n \in \mathbb{N}$. -->

The non-negative integer $n$ giving the number of "places" in the relation is called the arity, adicity or degree of the relation. A relation with $n$ "places" is variously called an $n$-ary relation.
Relations with a finite number of places are called finitary relations.

For instance, addition is a relation, which we will call $R_+$:

$$
\{(0, 0, 0), (1, 0, 1), (1, 1, 0), (2, 1, 1) \dots\}
$$

where the first, second and third element of each tuple represent the variables $z$, $a$, and $b$ in the equation $z = a + b$.

Another way to represent a relation is as a table.

| z | a | b |
|---|---|---|
| 5 | 2 | 3 |
| 4 | 2 | 2 |
| 4 | 3 | 1 |


## Reasoning Using (Functional) Relations

Suppose I tell you that $a = 2$ and $b = 3$, and I want the value of $z$.  We can provide an answer to this question by applying a restricting the relation to select only those values that are consistent with the given information, yielding:

| z | a | b |
|---|---|---|
| 5 | 2 | 3 |
| ~~4~~ | ~~2~~ | ~~2~~ |
| ~~4~~ | ~~3~~ | ~~1~~ |

Naturally, this operation is called a __selection__, and performed by an operation called $\sigma$ ("s" in sigma corresponds to "s" in selection).

The selection function $\sigma : \Phi \times \mathcal{R} \to \mathcal{R}$ filters out all elements of a relation $R \in \mathcal{R}$ (the set of relations) which are inconsistent with a predicate $\varphi \in \Phi$.

In this example, the selection predicate is $\varphi(x) := x_a = 2 \land x_b = 3$.
Applying selection operator $\sigma_\varphi$ to $R$ yields $R_\varphi = \sigma_\varphi(R_+)$ where $R_\varphi = \{x \mid \varphi(x), x \in R_+\}$.

After selection, a single row remains.
A relation with a single set is called a *singeleton* ($R_\varphi$ is the singleton set $(5, 2, 3)$).  The selection produces a singleton relation not just for $\varphi := x_a = 2 \land x_b = 3$, but forall values of $a$ and $b$.
In other words, given values for $a$ and $b$, there is always a single value of $z$.
In this case, we shall say $R$ is *functional* on $\{a, b\} \to \{z\}$.

__Definition__: A relation $R$ is functional on $\{x_1, \dots, x_n\} \to \{y_1, \dots, y_m \}$ if and only if all of the following conditions hold:
(i) for all $x_1, x_2, \dots, x_n$ $\sigma_\varphi(R)$ is a singleton relation where $\varphi = x_1 = x \land x_2 = x_2 \land \cdots \land x_n = x_n$

We can see then that $R_+$ is functional on $\{a, b\}$, on ${a, b}$

Why do functional relations matter?
They matter because 
 
2. Extract the $Z$ axis

## Reasoning Using Non-Functional Relations



Now suppose I tell you that $z = 4$ and I want the values of $a$ and $b$.
Applying the corresponding selection to $R_+$ yields a new relation:

| Z | A | B |
|---|---|---|
| ~~5~~ | ~~2~~ | ~~3~~ |
| 4 | 2 | 2 |
| 4 | 3 | 1 |

This time, after selection, infinitely many rows remain, two of which are shown here.
The primary idea that parametric relational programming inherits from parametric inversion is to parametrically represent this set.  To do this, we introduce the concept of **extending** a relation with a parameter space.
<!-- 
The relational perspective allows us to consider other things we might want to do with a relation than just compute the input given the output.

There are a few things to note:
- This relation is function on `(A, B) -> (Z,)` but not on `(Z,) -> (A, B)`
- Addition and subtraction are two sides of the same relation

Functions are relations that have the property that for any input in the relation there is a single output.

This property is important as it is a precondition for computing functions.  That is, using a programming language like Julia, we can define an algorithm which computes the output value of a function given the input value. -->


### Relational Extension

An extension to a relation introduces a new place.
To demonstrate, let us extend the addition relation with a new column $\theta$:

| Z | A | B | θ |
|---|---|---|---|
| 5 | 2 | 3 | 4 |
| 4 | 2 | 2 | 1 |
| 4 | 3 | 1 | 2 |

The purpose of an extension is to make the relational functional on all of its places.  Now:
- $R$ is functional on $\{z, \theta\} \to \{a, b\}$
- $R$ is functional on $\{a, \theta\} \to \{z, b\}$
- $R$ is functional on $\{b, \theta\} \to \{z, a\}$

__Definition:__ Formally, a relation $R_\theta$ is an extension to a $R$ if and only if:
(1)
(2) 

[TODO soundness / completeness]

### The Choose Operator
This sequence of four steps -- extending a relation, selecting a subset of it, projecting into onto some axes and -- are then a form of recipe.
Here, we'll give this sequence a name

$$
\text{choose}_{\varphi, \alpha} = \text{project}_\alpha \circ \text{select}_\varphi \circ \text{extend} =  \pi \circ \sigma \circ \epsilon
$$

## Programs as Relations

In reality, these relations are not represented explicitly as either sets or as tables.  Rather, they are represented as programs.

Let's start with a simple program.

```julia
function f(a, b)
  z = a * b + a
  return z
end
```

This program is a __straight-line__ program in the sense that it uses no loops or any form of recursion.
In addition it has no side effects, and hence it is a __functional__ program.

There are many different questions we might want to ask:
- Given values for $a$ and $b$, what is the value of $z$
- Given a value for $z$, provide a value for $a$ and $b$
- Given a value for $a$, provide a value for $b$ and $z$
- Given a value for $b$, provide a value for $a$ and $z$

To answer these questions, we want to follow the approach layed about above.  Unfortuantely, is not represented as an explicit enumerable set or table, not least be because R is infinite, and could not be represented explicitly.

### Ordering

The approach we will take is to __reoder__ f.

First, let's see the SSA IR form of `f`:

```julia
julia> @code_ir g(1, 2)
1: (%1, %2, %3)
  %4 = %2 * %3
  %5 = %4 + %2
  return %5
```

Here `%2` corresponds to `a`, `%3` to `b`, and `%5` to `z`.  `%4` corresponds to the intermediate unnamed value `a * b`.



In graphical form, this is:


The basic idea behind parametric relational programming is that there is a great deal of flexibility in the order in which we execute statements.
In this example, we know the value of the output $z$ and we want the inputs $a$ and $b$.

Here are two possible strategies:

1. Parametrically invert $+$ to yield values for $a$ and $v1$
2. Parametrically invert $*$ to yield values for $a$ and $b$

If we produced two different values for $a$ in these steps then that is an inconsistency error.  That is, we chose "wrong" parameter values.

But here's a better strategy that side steps this problem

1. Choose a value for $a$
2. Invert $+$ to yield values for $v1$ given the values for $a$ and $v2$
3. Invert $*$ to yield a value for $b$ given $a$



Q: Should we be able to reorient to internal values?

-- Can assume we start with some knowns, which are inputs.
-- What is a reorientation?  It
