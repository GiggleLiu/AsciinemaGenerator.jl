module AsciinemaGenerator

using REPL

export cast_file

Base.@kwdef struct JuliaInput
    input   # expression
    input_string::String = string(rmlines(input))

    delay::Float64
    prompt_delay::Float64
    char_delay::Float64 
    output_row_delay::Float64
    output_delay::Float64
end
Base.:(==)(a::JuliaInput, b::JuliaInput) = all(name->getfield(a, name) == getfield(b, name), fieldnames(JuliaInput))

struct ControlNode
    head::Symbol
    args::Vector{Any}
end
Base.:(==)(a::ControlNode, b::ControlNode) = a.head == b.head && a.args == b.args

LINEBREAK(t) = """[$t, "o", "\\r\\n\\u001b[0K"]"""
JULIA(t) = """[$t, "o", "\\r\\u001b[0K\\u001b[32m\\u001b[1mjulia> \\u001b[0m\\u001b[0m\\r\\u001b[7C"]"""
function JULIA_INIT()
    return raw"""[0.0, "o", "               \u001b[1m\u001b[32m_\u001b[0m\r\n   \u001b[1m\u001b[34m_\u001b[0m""" *
    raw"""       \u001b[0m_\u001b[0m \u001b[1m\u001b[31m_\u001b[1m\u001b[32m(_)\u001b[1m\u001b[35m_\u001b[0m     |  """ *
    raw"""Documentation: https://docs.julialang.org\r\n  \u001b[1m\u001b[34m(_)\u001b[0m     | """ *
    raw"""\u001b[1m\u001b[31m(_)\u001b[0m \u001b[1m\u001b[35m(_)\u001b[0m    |\r\n   \u001b[0m_ _   _| """ *
    raw"""|_  __ _\u001b[0m   |  Type \\\"?\\\" for help, \\\"]?\\\" for Pkg help.\r\n  \u001b[0m| | | | | | |/ _` |\u001b[0m  """ *
    raw"""|\r\n  \u001b[0m| | |_| | | | (_| |\u001b[0m  |  Version """ *
    string(VERSION) *
    " ($(Base.GIT_VERSION_INFO.date_string[1:10]))" * 
    raw"""\r\n \u001b[0m_/ |\\__'_|_|_|\\__'_|\u001b[0m  |  Official https://julialang.org/ release\r\n\u001b[0m|__/\u001b[0m                   |\r\n\r\n""" *
    raw"""\u001b[?2004h\r\u001b[0K\u001b[32m\u001b[1mjulia> \u001b[0m\u001b[0m\r\u001b[7C\r\u001b[7C"]"""
end

function generate(m::Module, commands::Vector{JuliaInput};
        width::Int, height::Int, start_delay::Float64,
        comment_delay::Float64,
        randomness::Float64,
        show_julia_version::Bool,
        tada::Bool,
        )
    s = """{"version": 2, "width": $width, "height": $height, "timestamp": $(round(Int, time())), "env": {"SHELL": "/usr/bin/zsh", "TERM": "xterm-256color"}}"""
    lines = [s]
    if show_julia_version
        push!(lines, JULIA_INIT())
    end
    t = start_delay
    for (k, command) in enumerate(commands)
        if command.input isa ControlNode
            if command.input.head == :delay
                t += command.input.args[1]
                continue
            elseif command.input.head == :comment
                push!(lines, JULIA(t))
                t += fluctuate(command.prompt_delay, randomness)
                #t, l = input_lines(t, "#" * command.input_string; command.char_delay)
                comment = "#" * command.input_string
                for c in split(comment, " ")
                    push!(lines, """[$t, "o", $(repr(c * " "))]""")
                    t += fluctuate(command.char_delay, randomness)
                end
                t += fluctuate(comment_delay, randomness)
                #append!(lines, l)
                push!(lines, LINEBREAK(t))
                k != length(commands) && push!(lines, LINEBREAK(t))
                continue
            else
                error("command type `$(command.input.head)` is not defined.")
            end
        end
        push!(lines, JULIA(t))
        t += fluctuate(command.prompt_delay, randomness)
        t, l = input_lines(t, command.input_string; command.char_delay)
        append!(lines, l)
        push!(lines, LINEBREAK(t))
        t += fluctuate(command.output_delay, randomness)
        os = output_string(m, command; width, height, suppressed=REPL.ends_with_semicolon(command.input_string))
        if !isempty(os)
            output_lines = split(os, "\n")
            t, l = multiple_lines(t, output_lines; delay=command.output_row_delay, randomness)
            append!(lines, l)
        end
        t += fluctuate(command.delay, randomness)
    end
    push!(lines, JULIA(t))
    tada && push!(lines, """[$(t), "o", "🎉"]""")
    push!(lines, """[$(t+0.2), "o", "\\r\\n"]""")
    return join(lines, "\n")
end

fluctuate(t, randomness) = max(t * (1 + randomness * randn()), 1e-3)

parsefile(file) = open(file) do f
    s = read(f, String)
    parseall(s)
end

"""
    cast_file(filename::String;
            mod::Module = @__MODULE__,
            start_delay::Float64 = 0.5,
            width::Int=82,
            height::Int=43,
            randomness::Float64 = 0.0,
            output_file = nothing,

            # initial values for statement configuration
            delay::Float64 = 0.2,
            prompt_delay::Float64 = 0.5,
            comment_delay::Float64 = 0.5,
            char_delay::Float64 = 0.05,
            output_row_delay::Float64 = 0.005,
            output_delay::Float64 = 0.5,

            show_julia_version::Bool=true,
            show_pkg_status::Bool=false,
            tada::Bool=false,
        ) -> String
    

Convert a Julia file to a `.cast` file that can be played by asciinema.
The return value is a string as the content of the `.cast` file.

### Keyword Arguments
The following keyword arguments are for global configurations,

* `mod` is the module to execute the input Julia script.
* `output_file` is the `.cast` file as output, the default value `nothing` for not generating a file.
* `start_delay` is time delay before running the first statement.
* `width` and `height` are the width and height of the terminal.
* `randomness` is the uncertainty in the time delay.

* if `show_julia_version` is true, show Julia welcome page.
* if `show_pkg_status`is true, show package status at the begining.
* if `tada` is true, show `🎉` at the end of the show.

The following keyword arguments are for the initial statement-wise configurations,

* `prompt_delay` is the time delay between `julia>` and the statement input.
* `comment_delay` is the time delay after a comment.
* `char_delay` is the time delay between typing two chars.
* `output_delay` is time delay between the input and the output of a statement.
* `output_row_delay` is time delay between rows of the output of a statement.
* `delay` is time delay after running a statement.

### Examples
```jldoctest; setup=:(using AsciinemaGenerator)
julia> using AsciinemaGenerator

julia> output_file = tempname()
"/tmp/jl_g7aZCDUbC7"

julia> cast_file(joinpath("test/test_input.jl"); output_file, mod=Main);

shell> asciinema play /tmp/jl_g7aZCDUbC7
```

The last line plays the clip, please refer the `Play` section of this docstring.

### Input file
The statement-wise arguments can also be specify in the input Julia source file. e.g.
```julia
shell> cat test/test_input.jl
@show "Hello"

using Pkg

#: Waiting for 5 seconds
#+ 5
#s delay=1.0; output_row_delay=0.3

println("haa"); Pkg.status()
```

Lines starting with `#s ` are for setting parameters, different assign statements should be separated by `;`.
Lines starting with `#+` are for inserting an extra time delay.
Other lines starting with `#` are regular comments, which will also be shown in the `.cast` file!

### Play
To install `asciinema`, please check the [official site](https://asciinema.org/docs/installation).
One can also deploy the `.cast` file in a website, please check the `demo` folder in the `demo` branch of this repo for a minimum [Franklin](https://github.com/tlienart/Franklin.jl) static site example.
"""
function cast_file(filename::String;
        mod::Module = @__MODULE__,
        start_delay::Float64 = 0.5,
        width::Int=82,
        height::Int=43,
        randomness::Float64 = 0.0,
        output_file = nothing,

        # initial values for statement configuration
        delay::Float64 = 0.1,
        prompt_delay::Float64 = 0.5,
        comment_delay::Float64 = 0.5,
        char_delay::Float64 = 0.05,
        output_row_delay::Float64 = 0.005,
        output_delay::Float64 = 0.5,

        show_julia_version::Bool=true,
        show_pkg_status::Bool=false,
        tada::Bool=false,
    )::String
    exs, strings = parsefile(filename)
    cmds = generate_commands(exs, strings; delay, prompt_delay, char_delay, output_row_delay, output_delay)
    if show_pkg_status
        insert!(cmds, 1, JuliaInput(:(using Pkg; Pkg.status()), "using Pkg; Pkg.status()", delay, prompt_delay, char_delay, output_row_delay, output_delay))
    end
    str = generate(mod, cmds; width, height, start_delay, randomness, show_julia_version, tada, comment_delay)
    if output_file !== nothing
        write(output_file, str)
    end
    return str
end

function generate_commands(exs, strings;
        delay::Float64,
        prompt_delay::Float64,
        char_delay::Float64,
        output_row_delay::Float64,
        output_delay::Float64,
    )
    cmds = JuliaInput[]
    for (input, input_string) in zip(exs, strings)
        if input isa ControlNode && input.head == :setting
            for ex in input.args
                @assert ex.head == :(=) "the delay argument should be something like, `delay = 3; output_delay=4`, got `$(ex)`"
                type = ex.args[1]
                if type == :delay
                    delay = ex.args[2]
                elseif type == :prompt_delay
                    prompt_delay = ex.args[2]
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
            push!(cmds, JuliaInput(; input, input_string, delay, prompt_delay, char_delay, output_row_delay, output_delay))
        end
    end
    return cmds
end

function multiple_lines(t::Float64, list; delay, randomness)
    lines = String[]
    for (i, ch) in enumerate(list)
        tch = tame(ch)
        push!(lines, """[$t, "o", "$tch"]""")
        if i !== length(list)
            push!(lines, LINEBREAK(t))
            t += fluctuate(delay, randomness)
        end
    end
    return t, lines
end

function output_string(m::Module, cmd::JuliaInput; width, height, suppressed)
    pipe = Pipe()
    io = IOContext(pipe, :color => true, :limit => true, :displaysize => (width, height))

    res = redirect_stdout(io) do
        try
            res = Core.eval(m, cmd.input)
            if !suppressed
                if res !== nothing
                    Core.eval(m, :(Base.show($io, MIME"text/plain"(), $res)))
                    println(io)
                    println(io)
                else
                    println(io)
                end
            else
                println(io)
            end
        catch e
            showerror(io, e)
            println(io)
            println(io)
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
        while pos <= lastindex(str) && str[pos] == '\n'
            pos = nextind(str, pos)
        end
        pos > lastindex(str) && break

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
        push!(strings, str[start:prevind(str, pos)])
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
    while stop <= lastindex(x) && x[stop] != '\n'
        stop = nextind(x, stop)
    end
    return (stop > lastindex(x) ? x[pos:end] : x[pos:prevind(x, stop)]), stop
end

end
