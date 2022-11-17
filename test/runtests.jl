using AsciinemaGenerator
using AsciinemaGenerator: JuliaInput
using Test

@testset "output" begin
    input = :(println(3); ones(10, 10))
    str = AsciinemaGenerator.output_string(JuliaInput(; input)) 
    @test str == "3\n10×10 Matrix{Float64}:\n 1.0  1.0  1.0  1.0  …  1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0  …  1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0"
    
    str = AsciinemaGenerator.output_string(JuliaInput(; input)) 
    @test str == "3\n10×10 Matrix{Float64}:\n 1.0  1.0  1.0  1.0  …  1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0  …  1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0"
end

@testset "output" begin
    input = :(println(3); ones(10, 10))
    sinput = "println(3); ones(10, 10)"
    t, lines = AsciinemaGenerator.input_lines(0.0, JuliaInput(; input, input_string=sinput, char_delay=0.05)) 
    @test t ≈ (length(sinput)-1) * 0.05
    @show sinput
    @show lines
    @test lines[2] == "[0.05, \"o\", \"r\"]"
end

@testset "test generation" begin
    commands = [JuliaInput(input=x) for x in [
        :(@show "Yao!"),
        :(using Pkg),
        :(Pkg.status())
    ]]
    @test AsciinemaGenerator.generate(Main, commands) isa String
end

@testset "cast file" begin
    output_file = tempname()
    cast_file(joinpath(@__DIR__, "test_input.jl"); output_file)
    @test isfile(output_file)
end