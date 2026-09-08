#s delay = 5
############  Coding Muscle Training 5: Performance tips  ############
# Please place your hand on your keyboard, type with me!
# Ready?
# 3. press SPACE to pause.
# 2. press → to move forward.
# 1. press ← to move backward.
# GO!

######### Measure the performance of your code #######
using BenchmarkTools

# the first example is about small matrix multiplication
@benchmark x * x setup=(x=randn(4,4))
#+ 5

# static immutable small array can be much faster! (at the cost of compiling time)
using StaticArrays
@benchmark sx * sx setup=(sx=SMatrix{4,4}(randn(4,4)))
#+ 5

using Profile

# the maximum number of samples and delay between two samples (1ms)
Profile.init(1000000, 0.001)

let x = randn(4,4)
    # the first run contains just in time compiling time, should be ignored
    x * x
    # profile the matmul for 1000000 times
    @profile for i=1:1000000
        x * x
    end
end
#+ 5

# the default printing is tree like, here we omit the lines with less than 10 samples
# each sample corresponds to 1ms.
Profile.print(; mincount=10, recur=:flat)

Profile.print(; mincount=10, format=:flat)

# please clear the collected sample in Profile module before doing another.
Profile.clear()

let x = randn(4,4)
    # the first run contains just in time compiling time, should be ignored
    x * x
    # profile the matmul for 1000000 times
    Profile.Allocs.@profile for i=1:1000000
        x * x
    end
end
#+ 5

# special note: memory allocations can also be profiled!
# please check: https://www.youtube.com/watch?v=BFvpwC8hEWQ

########## Avoid type instability ##########
# using global variables can cause type instability,
# the type of a variable can not be determined at runtime.
# this is because type of global variables can not be determined at any local scope.
global x = rand(1000)

function loop_over_global()
    s = 0.0
    for i in x
        s += i
    end
    return s
end
#+ 5

# type unstable code can be slow.
@benchmark loop_over_global()

# to detect type instability, just type
@code_warntype loop_over_global()

# the input type can be inferred!
function loop_over_input(x::AbstractVector{T}) where T
    s = zero(T)   # same element type as input vector element type T
    for i in x
        s += i
    end
    return s
end
#+ 5

@benchmark loop_over_input(x) setup=(x = rand(1000))
#+ 5

@code_warntype loop_over_input(rand(1000))

# another case that type can be unstable is the use of vector with non-concrete element type.
@benchmark loop_over_input(x) setup=(x = collect(AbstractFloat, rand(1000)))
#+ 5

# in some cases, global variables can not be avoided.
# One can use const to improve its performance.
const globalx = rand(1000)

# the type of const variable can not be changed (its value might change).
# this statement will error.
globalx = 3.0

# let us polish the version using global variable
function loop_over_const_global()
    s = 0.0
    for i in globalx
        s += i
    end
    return s
end
#+ 5

@benchmark loop_over_const_global()
#+ 5

# an alternative solution is annotate the type to help the compiler know its type
function loop_over_type_annotated_global()
    s = 0.0
    for i in x::Vector{Float64}
        s += i
    end
    return s
end
#+ 5

@benchmark loop_over_type_annotated_global()
#+ 5

# type declaration can also cause type instability
abstract type AbstractMod{N} <: Number end  # GF(N)

# this is a type stable one
struct Mod{N,T<:Integer} <: AbstractMod{N}
    val::T
    # the constructor
    function Mod{N,T}(val) where {N,T}
        new{N,T}(mod(val, N))
    end
    function Mod{N}(val::T) where {N,T}
        # forward the the previous constructor
        Mod{N,T}(val)
    end
end
#+ 5
# define the + operation
Base.:(+)(x::Mod{N,T}, y::Mod{N,T}) where {N,T} = Mod{N,T}(x.val + y.val)

# define the zero element (additive one)
Base.zero(::Type{Mod{N,T}}) where {N,T} = Mod{N,T}(zero(T))

# it is lower than type stable floating number operations, but faster than type unstable code
@benchmark loop_over_input(x) setup=(x = Mod{7}.(rand(1:100, 1000)))
#+ 5

# this is a type unspecified one
# special note: In a Julia REPL, one can use `↑` key to retrieve history input.
struct DynamicMod{N} <: AbstractMod{N}
    val
    function DynamicMod{N}(val) where {N}
        new{N}(mod(val, N))
    end
end
#+ 5
# similarly
Base.:(+)(x::DynamicMod{N}, y::DynamicMod{N}) where {N} = DynamicMod{N}(x.val + y.val)
Base.zero(::Type{DynamicMod{N}}) where {N} = DynamicMod{N}(0)  # integer content

# oops, it is super slow!
@benchmark loop_over_input(x) setup=(x = DynamicMod{7}.(rand(1000)))
#+ 5

# this is a mutable type stable one
mutable struct MutableMod{N,T<:Integer} <: AbstractMod{N}
    val::T
    # the constructor
    function MutableMod{N,T}(val) where {N,T}
        new{N,T}(mod(val, N))
    end
    function MutableMod{N}(val::T) where {N,T}
        # forward the the previous constructor
        MutableMod{N,T}(val)
    end
end
#+ 5
# define the + operation
Base.:(+)(x::MutableMod{N,T}, y::MutableMod{N,T}) where {N,T} = MutableMod{N,T}(x.val + y.val)

# define the zero element (additive one)
Base.zero(::Type{MutableMod{N,T}}) where {N,T} = MutableMod{N,T}(zero(T))

# it is slightly slower than immutable type
@benchmark loop_over_input(x) setup=(x = MutableMod{7}.(rand(1:100, 1000)))
#+ 5

# In conclution, the more (is mutable? type does not change?) you tell the compiler about your variables, the faster code it can generate.

########## Array performance ##########
# indexing over a range allocates!
@benchmark x[1:length(x)÷2] setup=:(x = randn(1000))
#+ 5

# taking a view is much faster.
@benchmark view(x, 1:length(x)÷2) setup=:(x = randn(1000))
#+ 5

# use the following macros,
# @inline, inlining a small function can improve performance. `@noinline` means do not automatically inline.
# @simd, let the compiler try using SIMD for some loops (the loop body should be simple enough).
# @inbounds, avoid boundary check.
# To know some advanced use of SIMD, please check: https://github.com/JuliaSIMD/LoopVectorization.jl
#
# Let us try writting the following inner product
@noinline function inner(x, y)
    s = zero(eltype(x))
    for i=eachindex(x)
        @inbounds s += x[i]*y[i]
    end
    return s
end
#+ 5

@noinline function innersimd(x, y)
    s = zero(eltype(x))
    @simd for i = eachindex(x)
        @inbounds s += x[i] * y[i]
    end
    return s
end
#+ 5

@benchmark inner(x, y) setup=(n = 1000;
                x = rand(Float32, n);
                y = rand(Float32, n))
#+ 5

@benchmark innersimd(x, y) setup=(n = 1000;
                x = rand(Float32, n);
                y = rand(Float32, n))
#+ 5

# for multi-threading, please check `Base.Threads` module:
# https://docs.julialang.org/en/v1/manual/multi-threading/
