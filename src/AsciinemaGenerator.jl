module AsciinemaGenerator

export cast_file

Base.@kwdef struct JuliaInput
    input   # expression
    input_string::String = string(rmlines(input))

    delay::Float64 = 0.5
    julia_delay::Float64 = 0.2
    char_delay::Float64 = 0.1
    output_row_delay::Float64 = 0.005
    output_delay::Float64 = 0.5
end

struct ControlNode
    head::Symbol
    args::Vector{Any}
end

LINEBREAK(t) = """[$t, "o", "\\r\\n\\u001b[0K"]"""
JULIA(t) = """[$t, "o", "\\r\\u001b[0K\\u001b[32m\\u001b[1mjulia> \\u001b[0m\\u001b[0m\\r\\u001b[7C"]"""

function generate(m::Module, commands::Vector{JuliaInput}; width::Int=82, height::Int=43, start_delay::Float64=0.5, randomness::Float64=0.5)
    s = """{"version": 2, "width": $width, "height": $height, "timestamp": $(round(Int, time())), "env": {"SHELL": "/usr/bin/zsh", "TERM": "xterm-256color"}}"""
    lines = [s]
    t = start_delay
    for (k, command) in enumerate(commands)
        if command.input isa ControlNode
            if command.input.head == :delay
                t += command.input.args[1]
                continue
            elseif command.input.head == :comment
                push!(lines, JULIA(t))
                t += fluctuate(command.julia_delay, randomness)
                t, l = input_lines(t, "#" * command.input_string; command.char_delay)
                append!(lines, l)
                push!(lines, LINEBREAK(t))
                k != length(commands) && push!(lines, LINEBREAK(t))
                continue
            else
                error("command type `$(command.input.head)` is not defined.")
            end
        end
        push!(lines, JULIA(t))
        t += fluctuate(command.julia_delay, randomness)
        t, l = input_lines(t, command.input_string; command.char_delay)
        append!(lines, l)
        push!(lines, LINEBREAK(t))
        t += fluctuate(command.output_delay, randomness)
        os = output_string(m, command; width, height)
        if !isempty(os)
            output_lines = split(os, "\n")
            t, l = multiple_lines(t, output_lines; delay=command.output_row_delay, randomness)
            append!(lines, l)
        end
        t += fluctuate(command.delay, randomness)
        k != length(commands) && push!(lines, LINEBREAK(t))
    end
    return join(lines, "\n")
end

fluctuate(t, randomness) = max(t * (1 + randomness * randn()), 1e-2)

parsefile(file) = open(file) do f
    s = read(f, String)
    parseall(s)
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
        randomness::Float64 = 1.0,
        output_file = nothing,
    )
    exs, strings = parsefile(filename)
    exs = rmlines.(exs)
    cmds = JuliaInput[]
    for (input, input_string) in zip(exs, strings)
        if input isa ControlNode && input.head == :setting
            for ex in input.args
                @assert ex.head == :(=) "the delay argument should be something like, `delay = 3; output_delay=4`, got `$(ex)`"
                type = ex.args[1]
                if type == :delay
                    delay = ex.args[2]
                elseif type == :julia_delay
                    julia_delay = ex.args[2]
                elseif type == :char_delay
                    char_delay = ex.args[2]
                elseif type == :output_row_delay
                    output_row_delay = ex.args[2]
                elseif type == :output_delay
                    output_delay = ex.args[2]
                else
                    error("variable `$type` not found.")
                end
            end
        else
            push!(cmds, JuliaInput(; input, input_string, delay, julia_delay, char_delay, output_row_delay, output_delay))
        end
    end
    str = generate(mod, cmds; width, height, start_delay, randomness)
    if output_file !== nothing
        write(output_file, str)
    end
    return str
end

function multiple_lines(t::Float64, list; delay, randomness)
    lines = String[]
    for (i, ch) in enumerate(list)
        tch = tame(ch)
        push!(lines, """[$t, "o", "$tch"]""")
        push!(lines, LINEBREAK(t))
        i !== length(list) && (t += fluctuate(delay, randomness))
    end
    return t, lines
end

function output_string(m::Module, cmd::JuliaInput; width, height)
    pipe = Pipe()
    io = IOContext(pipe, :color => true, :limit => true, :displaysize => (width, height))

    res = redirect_stdout(io) do
        try
            res = Core.eval(m, cmd.input)
            if res !== nothing
                show(io, "text/plain", res)
            end
        catch e
            showerror(io, e)
        end
    end
    close(Base.pipe_writer(io.io))
    return read(io.io, String)
end

function input_lines(t::Float64, input_string; char_delay)
    inputs = split(strip(input_string, '\n'), "\n")
    lines = String[]
    for (k, input) in enumerate(inputs)
        for (i, ch) in enumerate(input)
            push!(lines, """[$t, "o", $(repr(string(ch)))]""")
            i !== length(input) && (t += char_delay)
        end
        k == length(inputs) || push!(lines, """[$t, "o", "\\n\\r\\u001b[0K       "]""")
    end
    return t, lines
end

function tame(str::AbstractString)
    replace(str, "\e"=>"\\u001b", "\\\""=>"\\\\\\\"", "\""=>"\\\"", "\n"=>"\n\r")
end

"""
    rmlines(ex::Expr)

Remove line number nodes for pretty printing.
"""
rmlines(ex::Expr) = begin
    hd = ex.head
    if hd == :macrocall
        Expr(:macrocall, ex.args[1], nothing, rmlines.(ex.args[3:end])...)
    elseif hd == :block && length(ex.args) == 1  # unroll single statement block
        rmlines(ex.args[1])
    else
        tl = Any[rmlines(ex) for ex in ex.args if !(ex isa LineNumberNode)]
        Expr(hd, tl...)
    end
end
rmlines(@nospecialize(a)) = a

function parseall(str)
    pos = 1
    exs = []
    strings = String[]
    while true
        # cleanup leading line breaks
        while pos <= length(str) && str[pos] == '\n'
            pos += 1
        end
        pos > length(str) && break

        # detect comments
        sub = str[pos:end]
        if startswith(sub, "#+ ")  # delay
            c, pos = readuntil_linebreak(str, pos+3)
            push!(exs, ControlNode(:delay, Any[parse(Float64, c)]))
            push!(strings, c)
            continue
        elseif startswith(sub, "#s ")  # setting
            c, pos = readuntil_linebreak(str, pos+3)
            push!(exs, ControlNode(:setting, parse_kwargs(c)))
            push!(strings, c)
            continue
        elseif startswith(sub, "#")  # regular comments
            c, pos = readuntil_linebreak(str, pos+1)
            push!(exs, ControlNode(:comment, Any[c]))
            push!(strings, c)
            continue
        end

        start = pos
        ex, pos = Meta.parse(str, pos) # returns next starting point as well as expr
        ex === nothing && break
        push!(exs, ex)
        push!(strings, str[start:pos-1])
    end
    return exs, strings
end

function parse_kwargs(c::String)
    ex = Meta.parse(c)
    if ex === nothing
    elseif ex isa Expr
        if ex.head == :(=)
            return Any[ex]
        elseif ex.head == :toplevel
            return ex.args
        else
            error("parsed value is not a valid expression: $(ex)")
        end
    else
        error("parsed value is not an expression: $(ex)")
    end
end

function readuntil_linebreak(x::String, pos::Int)
    isempty(x) && return ("", pos)
    stop = pos
    while stop <= length(x) && x[stop] != '\n'
        stop += 1
    end
    return (stop > length(x) ? x[pos:end] : x[pos:stop-1]), stop
end

end
