module AsciinemaGenerator

export cast_file

Base.@kwdef struct JuliaInput
    input   # expression
    input_string::String = string(rmlines(input))

    delay::Float64 = 0.5
    julia_delay::Float64 = 0.05
    char_delay::Float64 = 0.05
    output_row_delay::Float64 = 0.01
    output_delay::Float64 = 0.5
    # TODO: add randomness
end

LINEBREAK(t) = """[$t, "o", "\\r\\n"]"""
JULIA(t) = """[$t, "o", "\\r\\u001b[0K\\r\\u001b[0K\\u001b[32m\\u001b[1mjulia> \\u001b[0m\\u001b[0m\\r\\u001b[7C"]"""

function generate(m::Module, commands::Vector{JuliaInput}; width::Int=82, height::Int=43, start_delay::Float64=0.5)
    s = """{"version": 2, "width": $width, "height": $height, "timestamp": $(round(Int, time())), "env": {"SHELL": "/usr/bin/zsh", "TERM": "xterm-256color"}}"""
    lines = [s]
    t = start_delay
    for (k, command) in enumerate(commands)
        push!(lines, JULIA(t))
        t += command.julia_delay
        t, l = input_lines(t, command)
        append!(lines, l)
        push!(lines, LINEBREAK(t))
        t += command.output_delay
        os = output_string(m, command; width, height)
        if !isempty(os)
            output_lines = split(os, "\n")
            t, l = multiple_lines(t, output_lines; delay=command.output_row_delay)
            append!(lines, l)
        end
        t += command.delay
        k != length(commands) && push!(lines, LINEBREAK(t))
    end
    return join(lines, "\n")
end

parsefile(file) = open(file) do f
    s = read(f, String)
    s = join(["quote", s, "end"], ";")
    Meta.parse(s)
end

# TODO: parse manually, with delay
function cast_file(filename;
        mod::Module = @__MODULE__,
        delay::Float64 = 0.5,
        julia_delay::Float64 = 0.05,
        char_delay::Float64 = 0.05,
        output_row_delay::Float64 = 0.01,
        output_delay::Float64 = 0.5,
        start_delay::Float64 = 0.5,
        width::Int=82,
        height::Int=43,
        output_file = nothing,
    )
    ex = rmlines(parsefile(filename))
    cmds = JuliaInput[]
    for exi in ex.args[1].args
        push!(cmds, JuliaInput(; input=exi, delay, julia_delay, char_delay, output_row_delay, output_delay))
    end
    str = generate(mod, cmds; width, height, start_delay)
    if output_file !== nothing
        write(output_file, str)
    end
    return str
end

function multiple_lines(t::Float64, list; delay)
    lines = String[]
    for (i, ch) in enumerate(list)
        push!(lines, """[$t, "o", "$(tame(ch))"]""")
        push!(lines, LINEBREAK(t))
        i !== length(list) && (t += delay)
    end
    return t, lines
end

function output_string(m::Module, cmd::JuliaInput; width=60, height=40)
    pipe = Pipe()
    io = IOContext(pipe, :color => true, :limit => true, :displaysize => (width, height))

    res = redirect_stdout(io) do
        try
            res = Core.eval(m, cmd.input)
            if res !== nothing
                show(io, "text/plain", res)
            end
        catch e
            show(io, "text/plain", e)
        end
    end
    close(Base.pipe_writer(io.io))
    return read(io.io, String)
end

function input_lines(t::Float64, cmd::JuliaInput)
    sinput = cmd.input_string
    lines = String[]
    for (i, ch) in enumerate(sinput)
        push!(lines, """[$t, "o", $(repr(string(ch)))]""")
        i !== length(sinput) && (t += cmd.char_delay)
    end
    return t, lines
end

function tame(str::AbstractString)
    replace(str, "\e"=>"\\u001b", "\""=>"\\\"")
end

"""
    rmlines(ex::Expr)

Remove line number nodes for pretty printing.
"""
rmlines(ex::Expr) = begin
    hd = ex.head
    if hd == :macrocall
        Expr(:macrocall, ex.args[1], nothing, rmlines.(ex.args[3:end])...)
    else
        tl = Any[rmlines(ex) for ex in ex.args if !(ex isa LineNumberNode)]
        Expr(hd, tl...)
    end
end
rmlines(@nospecialize(a)) = a

end
