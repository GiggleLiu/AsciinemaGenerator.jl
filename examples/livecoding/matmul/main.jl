#s output_delay = 0.01; prompt_delay=0.2
matmul(A, B) = A * B;

# 看看函数实例 (compiled method instances)
using MethodAnalysis

methodinstances(matmul)

#+ 3

# 定义两个矩阵，第一个参数是类型
A = randn(Float64, 100, 100);
B = randn(Float64, 100, 100);

#s output_delay = 0.8
@time matmul(A, B);  # matrix multiplication, 1st run

# 函数实例的数目 +1
methodinstances(matmul)

#s output_delay = 0.01
@time matmul(A, B);  # matrix multiplication, 2nd run

methodinstances(matmul)

# 看看类型推导的结果
@code_warntype matmul(A, B)

#+ 3

# 接下来测试 Tropical 代数的矩阵乘法
using TropicalNumbers

# 所谓 Tropical 代数，就是把 `*` 操作映射到实数的 `+` 函数
at, bt = Tropical(2.0), Tropical(3.0)
at * bt
# 把 `+` 操作映射到实数的 `max` 函数
at + bt

# 现在把 A 与 B 矩阵的元素类型转成 Tropical 代数类型
At = Tropical.(A);  # `.` means broadcasting, which is similar to Matlab
Bt = Tropical.(B);

#s output_delay = 0.6
@time matmul(At, Bt);  # tropical matrix multiplication, 1st run

# 函数实例的数目 +1
methodinstances(matmul)

#s output_delay = 0.01
@time matmul(At, Bt);  # tropical matrix multiplication, 2nd run

# 看看类型推导的结果
@code_warntype matmul(At, Bt)
