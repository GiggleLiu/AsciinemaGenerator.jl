using AsciinemaGenerator
using AsciinemaGenerator: JuliaInput, rmlines
using Test

@testset "output" begin
    input = :(println(3); ones(10, 10))
    str = AsciinemaGenerator.output_string(@__MODULE__,
        JuliaInput(; input, delay=0.1, char_delay=0.1, output_delay=0.1, output_row_delay=0.01, prompt_delay=0.1),
        width=82, height=43, suppressed=false) 
    @test str == "3\n10×10 Matrix{Float64}:\n 1.0  1.0  1.0  1.0  …  1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0  …  1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n 1.0  1.0  1.0  1.0     1.0  1.0  1.0\n\n"
    
    str = AsciinemaGenerator.output_string(@__MODULE__,
        JuliaInput(; input, delay=0.1, char_delay=0.1, output_delay=0.1, output_row_delay=0.01, prompt_delay=0.1),
        width=82, height=43, suppressed=true) 
    @test str == "3\n\n"
end

@testset "rmlines" begin
    @test rmlines(quote begin x=3 end end) == :(x=3)
end

@testset "output" begin
    input = :(println(3); ones(10, 10))
    sinput = "println(3); ones(10, 10)"
    t, lines = AsciinemaGenerator.input_lines(0.0, sinput; char_delay=0.05)
    @test t ≈ (length(sinput)-1) * 0.05
    @show sinput
    @show lines
    @test lines[2] == "[0.05, \"o\", \"r\"]"
end

@testset "test generation" begin
    commands = [JuliaInput(input=x, delay=0.1, char_delay=0.1, output_delay=0.1, output_row_delay=0.01, prompt_delay=0.1) for x in [
        :(@show "Yao!"),
        :(using Pkg),
        :(Pkg.status())
    ]]
    @test AsciinemaGenerator.generate(@__MODULE__, commands; width=82, height=40, show_julia_version=true, start_delay=0.5, randomness=0.0, tada=true) isa String
end

@testset "cast file" begin
    output_file = tempname()
    cast_file(joinpath(@__DIR__, "scripts", "test_input.jl"); output_file, show_pkg_status=true, show_julia_version=true)
    @test isfile(output_file)

    # incorrect file
    @test_throws ErrorException cast_file(joinpath(@__DIR__, "scripts", "error_cfg.jl"); output_file, show_pkg_status=true, show_julia_version=true)
end

@testset "read until line break" begin
    @test AsciinemaGenerator.readuntil_linebreak("1231231\n", 1) == ("1231231", 8)
    @test AsciinemaGenerator.readuntil_linebreak("  \n1231231\nadsf", 5) == ("231231", 11)
    @test AsciinemaGenerator.readuntil_linebreak("1231231", 2) == ("231231", 8)
    @test AsciinemaGenerator.readuntil_linebreak("1231231", 12) == ("", 12)
    @test AsciinemaGenerator.readuntil_linebreak("", 1) == ("", 1)
end

@testset "parseall" begin
    @test AsciinemaGenerator.parseall("")[1] == []
    @test AsciinemaGenerator.parseall("")[2] == []
    str = """@show "Hello"\n\nusing Pkg\n\n#: Waiting for 5 seconds
#+ 5
#s delay=1.0; output_row_delay=0.3; char_delay=0.05; prompt_delay=0.1; output_delay=0.5

println("haa"); Pkg.status()"""
    exs, strings = AsciinemaGenerator.parseall(str)
    @test length(exs) == 6
    @test length(strings) == 6

    cmds = AsciinemaGenerator.generate_commands(exs, strings; delay=0.5, prompt_delay=0.05, output_delay=0.5, output_row_delay=0.01, char_delay=0.05)
    @test length(cmds) == 5
    @test cmds[1].input.head == :macrocall
    @test cmds[2] == JuliaInput(:(using Pkg), "using Pkg", 0.5, 0.05, 0.05, 0.01, 0.5)
    @test cmds[3] == JuliaInput(AsciinemaGenerator.ControlNode(:comment, Any[": Waiting for 5 seconds"]), ": Waiting for 5 seconds", 0.5, 0.05, 0.05, 0.01, 0.5)
    @test cmds[4] == JuliaInput(AsciinemaGenerator.ControlNode(:delay, Any[5.0]), "5", 0.5, 0.05, 0.05, 0.01, 0.5)
    @test cmds[5] == JuliaInput(:($(Expr(:toplevel, :(println("haa")), :(Pkg.status())))), "println(\"haa\"); Pkg.status()", 1.0, 0.1, 0.05, 0.3, 0.5)
end
