#s delay = 5
############  Coding Muscle Training 4: Functions and multiple dispatch  ############
# Please place your hand on your keyboard, type with me!
# Ready?
# 3. press SPACE to pause.
# 2. press → to move forward.
# 1. press ← to move backward.
# GO!

######### Function definition #########
# the following definitions are equivalent
# key word arguments are separated from positionoal arguments by ;
function h(x, y; kw=3.0)
    return (x + y) * kw
end

# implicitly return (returns the last expression)
function h(x, y; kw=3.0)
    (x + y) * kw
end

# one liner
h(x, y; kw=3.0) = (x + y) * kw

# functions can be defined implicitly
h_impl = function (x, y)
    x + y
end
h_impl(2, 3)

# lambda expression
h_impl2 = (x, y) -> x+y
h_impl2(2, 3)

# to overload a function in another module
# either import it
import Base: sin
sin(x::String) = "sin($x)"
sin("x")

# or overload it explicitly
Base.cos(x::String) = "cos($x)"
cos("x")

# Special note: for operators like `+`, one should quote it with :() to avoid ambiguity.
Base.:(+)(a::String, b::String) = a * " + " * b
"x" + "y"

######### Multiple dispatch #########
# dispatch over any type
f(x::Any, y::Any) = "any"
# equivalently, it can be written as
f(x, y) = "any"

# function call
f(3, 4)

# dispatch over regular types
f(x::Int, y::Int) = "integer: $x, $y"
# although integer is any, the concrete one wins.
f(3, 3)
# the previous function is 
f("some", "string")

# dispatch over types with type parameters
f(x::Complex{T}, y::Complex{T}) where T = "complex: $x, $y of type $T"
f(2+3.0im, 1+2.0im)

# it is different from the following specification
f(x::Complex{T1}, y::Complex{T2}) where {T1, T2} = "complex: $x, $y of type $T1, $T2"
f(2+3.0im, 1+2.0im)
# it is called only if 
f(2+3.0im, 1f0+2f0im)

# dispatch over type of types
f(x::Type{T}, y::Type{T}) where T = "type: $T"
f(ComplexF64, ComplexF64)

# dispatch over functions
f(x::typeof(f), y::typeof(f)) = "f"
f(f, f)

# dispatch over a union type
f(x::Union{Complex, Real}, y::Union{Complex, Real}) = "complex or real"
f(3.0im, 3)

# ambiguity error
g(x::Union{Complex{T}, T}, y::Complex{T}) where T<:Real = "1: $(typeof(x)) & $(typeof(y))"
g(x::Real, y::Complex{T}) where T<:Real = "2: $(typeof(x)) & $(typeof(y))"
g(3.0, 4.0im)

# one can call the desired function explicitly
invoke(g, Tuple{Union{Complex{T}, T}, Complex{T}} where T<:Real, 3f0im, 4f0im)

# or define a new function that more concrete than both.
g(x::T, y::Complex{T}) where T<:Real = "3: $(typeof(x)) & $(typeof(y))"
g(3.0, 4.0im)
