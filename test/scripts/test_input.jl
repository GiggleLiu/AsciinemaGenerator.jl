@show "Hello"

using Pkg

#: Waiting for 5 seconds
#+ 5
#s delay=1.0; output_row_delay=0.3; prompt_delay=0.1; output_delay=0.5; char_delay=0.05

println("haa"); Pkg.status()

x = 3
println("haa $x");