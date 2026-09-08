#s delay = 5
############  Coding Muscle Training 6: Meta-programming  ############
# Please place your hand on your keyboard, type with me!
# Ready?
# 3. press SPACE to pause.
# 2. press → to move forward.
# 1. press ← to move backward.
# GO!

# functional operations
v = collect(-1:0.5:1)

# map(f, v) returns [f(v[1]), f(v[2]), f(v[3])]
map(x->x^2, v)

# reduce(f, v) returns f(f(v[1], v[2]), v[3])
reduce(+, v)

# foldl and foldr are similar to reduce, but with guaranteed left and right associativity.
# to see the difference
reduce((x, y)->(x, y), [1,2,3,4])
foldl((x, y)->(x, y), [1,2,3,4])
foldr((x, y)->(x, y), [1,2,3,4])

# mapreduce(r, m, v) returns r(r(m(v[1]), m(v[2])), m(v[3]))
# we can define the l-2 norm function as bellow.
mynorm(v) = sqrt(mapreduce(x->x^2, +, v))

using LinearAlgebra
mynorm(v) ≈ LinearAlgebra.norm(v)

# a simpler way to implement l2 norm is
mynorm2(v) = sqrt(sum(abs2, v))
mynorm2(v) ≈ LinearAlgebra.norm(v)  # input ≈ by typing \approx<TAB>

# similar to `sum`, functions such as `prod`, `any` and `all` can also take a function as the first arugment
prod(x->exp(abs2(x)), v)
all(>(0), v)
any(iszero, v)
count(iszero, v)

# unique values and allunique
unique(v)
allunique(v)

# foreach
foreach(println, v)

# zip
w = 1:length(v)
foreach(println, zip(w, v))

##### Getting Extremas ######
# get the maximum/minimum value
maximum(v)
minimum(v)
# locate the maximum/minimum value
argmax(v)
argmin(v)
# or both location and value
findmax(v)
findmin(v)

# locate by condition, findall(f, v)
findall(>=(0.5), v)

# replace
replace(v, 0.0=>Inf)

######## Linear algebra ########
# linear solver
A = randn(4, 4)
b = randn(4)
# the following two statements returns the same value
A \ b ≈ pinv(A) * b

# pinv is speudo-inverse, the matrix inverse is inv.
# since A is full rank
rank(A)
# matrix inverse is equivalen to matrix pseudo-inverse
inv(A) ≈ pinv(A)

# NOTE: the outer product has rank 1
rank(b * b')

# which can also been seen from the their singular values
res = svd(A)

res.S

# check the correctness
res.U * Diagonal(res.S) * res.Vt ≈ A

# the spectrum of b * b'
svd(b * b').S

# similarly, eigenvalues can be computed with
eigen(A)

# qr decomposition
qr(A)

# lu decomposition
lu(A)

######### Sparse Matrices ##########
using SparseArrays
# a random sparse 100 x 100 matrix of density of nonzero elements being 0.1
sp = sprand(100, 100, 0.1)

# number of nonzero elements
nnz(sp)

# convert to regular matrix
Matrix(sp)