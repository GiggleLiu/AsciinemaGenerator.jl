using AsciinemaGenerator
using AsciinemaGenerator: JuliaInput
using Test

@testset "output" begin
    input = :(println(3); ones(10, 10))
    str = AsciinemaGenerator.output_string(@__MODULE__, JuliaInput(; input)) 
    @test str == "3\n10×10 Matrix{Float64}:\n 1.0  1.0  1.0  1.0  …  1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0  …  1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0"
    
    str = AsciinemaGenerator.output_string(@__MODULE__, JuliaInput(; input)) 
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
    @test AsciinemaGenerator.generate(@__MODULE__, commands) isa String
end

@testset "cast file" begin
    output_file = tempname()
    cast_file(joinpath(@__DIR__, "test_input.jl"); output_file)
    @test isfile(output_file)
end

@testset "read until line break" begin
    @test AsciinemaGenerator.readuntil_linebreak("1231231\n", 1) == ("1231231", 8)
    @test AsciinemaGenerator.readuntil_linebreak("  \n1231231\nadsf", 5) == ("231231", 11)
    @test AsciinemaGenerator.readuntil_linebreak("1231231", 2) == ("231231", 8)
    @test AsciinemaGenerator.readuntil_linebreak("1231231", 12) == ("", 12)
    @test AsciinemaGenerator.readuntil_linebreak("", 1) == ("", 1)
end

@testset "parseall" begin
    @test AsciinemaGenerator.parseall("") == []
    str = "@show \"Hello\"\n\nusing Pkg\n\n#: Waiting for 5 seconds\n#+ 5\n\nprintln(\"haa\"); Pkg.status()"
    @test length(AsciinemaGenerator.parseall(str)) == 5
end