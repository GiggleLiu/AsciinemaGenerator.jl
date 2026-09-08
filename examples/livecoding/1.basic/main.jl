#s delay = 5
#########  Coding Muscle Training 1: Basic types and control flow  #########
# Please place your hand on your keyboard, type with me!
# Ready?
# 3. press SPACE to pause.
# 2. press → to move forward.
# 1. press ← to move backward.
# GO!

########### Basic types ###########
# boolean variables
true isa Bool
# size in bytes (1 byte = 8 bits)
sizeof(Bool)
# not
!true
# and
true && false
# or
true || false
# xor: type \xor<TAB>
# If the xor operator does not display in your terminal, try typing: xor(true, false), check https://docs.julialang.org/en/v1/manual/unicode-input/ for other unicode inputs.
# `a ⊻ b` returns true if and only if `a` and `b`.
true ⊻ false
#+ 10

# integers
3 isa Int
0x3 isa UInt8  # 8 bit, unsigned integer
#+ 3
# hint: try typing `bits<TAB>(3)`
bitstring(3)
bitstring(0x3)
sizeof(3)
sizeof(0x3)
# operations
7 % 3   # modulus
7 / 3   # / returns a floating point number
7 ÷ 3   # ÷ (by typing: \div<TAB>) returns an integer
7 << 1  # bit shift left, learn more about bitwise shift: https://en.wikipedia.org/wiki/Arithmetic_shift
7 >> 1  # bit shift right
7 | 1  # bit-wise or: learn more about bitwise operators: https://en.wikipedia.org/wiki/Bitwise_operation#Bitwise_operators
7 & 1  # bit-wise and
7 ⊻ 1  # bit-wise xor: type \xor<TAB>

# floating point numbers and complex numbers
# operator isa means "is a"
3.2 isa Float64
3.2e2 isa Float64
3.2f2 isa Float32
3.2 + 3im isa ComplexF64
# special note: π (type \pi<TAB>) and ℯ (type \euler<TAB>) are Irrational
typeof(π)
typeof(ℯ)

# operations
3.0 ^ 3   # power

# string tuples and vector
"3.0" isa String
(1, "3.0") isa Tuple
# tuple can be indexed
(1, "3.0")[1]   # the first element

# pair can be regarded as a length-2 tuple.
(3.0=>"3.0") isa Pair
#+ 3
# pair has two fields, `first` and `second`
(3.0=>"3.0").first
(3.0=>"3.0").second

# vector
[2, 3.0] isa Vector

# ranges
1:10 isa UnitRange # 1, 2, ..., 10
length(1:10)

1:2:10 isa StepRange

# dict
d = Dict(3.0=>"three", 4.0=>"four")
d isa Dict
# keys, and values of a dict
keys(d)
values(d)

# get dict element
d[3.0]
# using `get`, you can set the default value
get(d, 3.0, "not exist")

get(d, 5.0, "not exist")
# use `haskey` to check whether a key exists
haskey(d, 3.0)

# types can be used for conversion
UInt64(3) isa UInt64
Float32(3) isa Float32
# vectors and tuples can be created using splatting: `some_iterable...`
# splatting means unpacking an iterable.
[(1, "3.0")...]
# for tuple, you must add a "," after the splitting to avoid confusing with splatting in a function call f(args...).
([1, 3.0]...,)
((3.0=>"3.0")...,)
(1:2:10...,)
[1:2:10...]
[Dict(3.0=>"three", 4.0=>"four")...]
# equivalently
collect(1:2:10)

# the ranges of types
typemin(Int)
typemax(Int)

typemin(UInt64)
typemax(UInt64)

typemin(Float64)
typemax(Float64)

# the zero and one element of types
zero(Float64)
one(Float64)

# What is ∞ * 0?
0.0 * Inf

Inf == Inf

# A special note: NaN is not equal to any value, including itself.
NaN == NaN

# precision of floating point numbers (floating point number distance at 1.0)
eps(Float32)

eps(Float64)

# rounding error is unbiquitus in floating point numbers
1.0 == nextfloat(1.0)  # nextfloat returns the minimum floating point number greater than the input value.

# we prefer using `≈` (typed with \approx<TAB>) in many practical using cases
1.0 ≈ nextfloat(1.0)

########### Arbitary precision ###########
# numbers can overflow
let     # let creates a local scope
    x = 1
    for i=1:100  # iterates over 1, 2, ..., 100
        x *= i
    end
    x   # the (implicitly) returned value
end

# BigInt uses arbitary precision, it avoids overflow
let
    x = BigInt(1)
    for i=1:100
        x *= i
    end
    x
end

########### Control flows ###########
# block statement
# block statement is trivial, it is just a sequence of operations
a = 0; a += 1; a+=2; a

# or equivalently
begin  # the begin statement does create a local scope.
    a = 0
    a += 1
    a+=2
    a
end

# for statement
# the following two statements are the same
for i in 1:3
    # `println` is `print` + <LINEBREAK>
    println(i)
end

for i = 1:3
    println(i)
end

# declare a variable without initialization
#s output_delay = 3
let   # the `let` statement creates a local scope
    for i = 1:3  # the `for` statement creates a local scope
        j = i==1 ? 1 : j + 1   # j is not in the outer scope
        # `i==1 ? 1 : j + 1` means, if i==1, return 1, else return j+1
    end
    j  # can not access variables in a local scope
end
#s output_delay = 0.5

let
    local j   # declared without initialization
    for i = 1:3
        j = i==1 ? 1 : j + 1
    end
    j
end

# using global variables
global_j = 0

let
    for i=1:5
        global_j += 1  # can not access global variables at a local scope
    end
end

let
    for i=1:5
        global global_j += 1  # this one works!
    end
end

global_j


# Special Note: unlike the let statement, the block statement runs in the current scope instead of creating a local one.
#
# if statement
# we can use if statement to find out all prime numbers
using Primes  # REPL might require you install this package, type `y` to confirm.

for i=1:typemax(Int8)
    if isprime(i)
        println(i)
    end
end

# equivalently, you can use a while statement
let i=Int8(0)
    while i < typemax(Int8)
        i += Int8(1)
        if isprime(i)
            println(i)
        end
    end
end

# A better approach:
# create a UnitRange for all positive Int8 numbers.
ints = Int8(1):typemax(Int8)
# then create a boolean vector for indexing using broadcasting operation: `.`
boolean_mask = isprime.(ints)
# the locations marked with 1 will be collected to a vector
ints[boolean_mask]

# even shorter, you can use list comprehension
[x for x in Int8(1):typemax(Int8) if isprime(x)]

# or even shorter with filter
filter(isprime, Int8(1):typemax(Int8))

# check the docstring of filter with the `@doc` macro
@doc filter

# if ... elseif ... else ... end
function compare(x,y)
    if x < y
        relation = "less than"
    elseif x == y
        relation = "equal to"
    else
        relation = "larger than to"
    end
    println("$x is $relation $(y).")  # `$` for interpolation
end

compare(3, 4)

# Error handling
# try ... catch ... finally ... end
try
    x = [1]
    x[0]   # Julia counts from 1!
catch e
    @info "get error $e"  # @info is a fancy way of printing
    throw(e)
finally
    println("I will be executed anyway ;D")
end
