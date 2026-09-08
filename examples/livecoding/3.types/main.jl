#s delay = 5
##########  Coding Muscle Training 3: Data types  ############
# Please place your hand on your keyboard, type with me!
# Ready?
# 3. press SPACE to pause.
# 2. press → to move forward.
# 1. press ← to move backward.
# GO!

### Primitive Types ############
# Primitive types are building blocks of other types
isprimitivetype(Float64)

# Primitive types do not contain any fields.
fieldnames(Float64)

# concrete type is a type that can be allocated in memory. It can not be subtyped!
isconcretetype(Float64)

# we can check its size in byte (1 type = 8 bit).
sizeof(Float64)

# any type is the parent type of other types
Float64 <: Any

# Float64 subtypes AbstractFloat
supertype(Float64)

Float64 <: AbstractFloat

# list all the subtypes of AbstractFloat.
subtypes(AbstractFloat)

# AbstractFloat is not a concrete type,
# In a type tree, only leaf types can be initialized in memory.
isconcretetype(AbstractFloat)

# an abstract type does not have definite size
#s output_delay = 3
sizeof(AbstractFloat)
#s output_delay = 0.5

# AbstractFloat is a subtype of Real
supertype(AbstractFloat)
AbstractFloat <: Real

# Real is a subtype of Number
Real <: Number

# Let us visualize the type tree
using AbstractTrees

AbstractTrees.children(x::Type) = subtypes(x)

print_tree(Number)

############ Composite types ############
# Complex numbers are not primitive types
isprimitivetype(ComplexF64)

# This is because it contains two fields:
fieldnames(ComplexF64)

# It is a composite type with "TYPE PARAMETERS"
ComplexF64 === Complex{Float64}   # `===` more strict version of `==`, it also checks type.

# ComplexF64 is a subtype of Complex
ComplexF64 <: Complex

# Type parameters are a part of a type.
# For example, a type is not concrete if its type parameters are not provided.
# Because without a type parameter, the memory can not be initialized!
isconcretetype(Complex)

isconcretetype(ComplexF64)

############ The union of types ############
# Julia does not have multi-inheritance (a type can not have multiple parent types)
# If a function works on both Real and Complex numbers, you can use
RealAndComplex = Union{Complex,Real}
Complex <: RealAndComplex
Real <: RealAndComplex

# A Union two concrete types is not concrete
isconcretetype(Union{ComplexF64, Float64})


############ Define you own types ############
# Let us create a abstract type for finite field algebra that subtypes Number.
# An abtract type should not contain any field. It can be defined with the `abstract type` keyword
abstract type AbstractMod{N} <: Number end  # GF(N)

# Then we define a concrete type with single field `val`
struct Mod{N,T} <: AbstractMod{N}
    val::T
end
# It has two fields, `N` is the modulus, `T` is the type of its storage.
# For example, the finite field algebra GF(7) can be
Mod{7, Int}

# This definition of Mod is not complete yet since we haven't defined any functions on it.
# For the complete implementation: https://github.com/scheinerman/Mods.jl

# A special note: users can define a customized primitive type for his specialized machine,
#                 but it is an advanced topic that beyond the scope of this tutorial.
#                 https://docs.julialang.org/en/v1/manual/types/

############ Instantiation of types ############
# One can create a 
m = Mod{7,Int}(3)

# m is an instance of Mod
m isa Mod{7, Int}
m isa Mod

# It has the size equal to the integer size (8 bytes in a double precision machine)
sizeof(Mod{7, Int})

# but the allocation is not in the main memory,
# this is because the compiler knows this element type can fit into the register.
@allocated Mod{7,Int}(3)

@doc @allocated

# The field type can be left unspecified.
# if you have defined the finite field algebra without content type specification,
struct DynamicMod{N} <: AbstractMod{N}
    val
end

# It is a concrete type, so it has a fixed size
isconcretetype(DynamicMod{3})
sizeof(DynamicMod{3})

# But this size is not the actual size, it is just the size of the pointer!
# i.e. that content can be anything, but the "size" of its instances is always 8.
sizeof(DynamicMod{3}("asdf"))

# Having a field with unspecified type can be dangerous,
using BenchmarkTools

@benchmark let
    # here "." means broadcast over the target range 1, 2, ..., 10.
    v = DynamicMod{7}.(1:1000)
    cum = 0  # for cumulation
    for item in v
        cum += item.val    # the `val` field of item is added to cum
    end
    # returns the cumulated value and the memory allocation
    cum
end

# similarly, for Mod{7, Int} type
@benchmark let
    v = Mod{7, Int}.(1:1000)
    cum = 0
    for item in v
        cum += item.val
    end
    cum
end

# The allocation is optimized away if the field type is specified.
# For runtime performance, we should try our best to avoid t using type unspecified field.
# 
# another reason is a type with unspecified field can not be tiled into an array (causing performance issue) or used on GPU.
# To check whether your type can be tiled into an array or used on GPU, just type
isbitstype(Mod{7, Int})

isbitstype(DynamicMod{7})

# unspecified types or Any type is needed only when type abusing is a problem to your program.
# for type abusing: https://docs.julialang.org/en/v1/manual/performance-tips/#The-dangers-of-abusing-multiple-dispatch-(aka,-more-on-types-with-values-as-parameters)
# 
# Having multiple type parameters is not very convenient, then you might type alias
Mod64{N} = Mod{N, Int}

Mod64{7} === Mod{7, Int64}

# A type can be declared as mutable
# The worse implementation of the finite field algebra type could be
mutable struct MutableDynamicMod{N} <: AbstractMod{N}
    val
end

# the field of a mutable type can be changed.
md = MutableDynamicMod{7}(3)

md.val = 10

md

# no free lunch, the performance is terrible
@benchmark let
    v = MutableDynamicMod{7}.(1:1000)
    cum = 0
    for item in v
        cum += item.val
    end
    cum
end

# What is the type of type? Type!
Mod isa Type

######### Tuple types ##########
# A tuple is different from a vector in that it contains type information of all of its elements.
typeof((1, 2, 3.0))
# the returned value has type Tuple{Int64, Int64, Float64}.

# A similar statement converts the vector element type to Float64
typeof([1, 2, 3.0])

# When type conversion is not available, the vector parameter type becames Any.
typeof([1, 2, "I am a string"])

# Then how do we represent the type for a integer tuple of size `N`? We need `NTuple{N,Int}`.
Tuple{Int64, Int64, Int64} === NTuple{3,Int64}
