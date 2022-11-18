# AsciinemaGenerator

[![Build Status](https://github.com/GiggleLiu/AsciinemaGenerator.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GiggleLiu/AsciinemaGenerator.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/GiggleLiu/AsciinemaGenerator.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/GiggleLiu/AsciinemaGenerator.jl)

This package mainly provides a single function `cast_file` that generates a `.cast` file from your Julia source code.

```julia
help?> cast_file
search: cast_file

  cast_file(filename::String;
          mod::Module = @__MODULE__,
          start_delay::Float64 = 0.5,
          width::Int=82,
          height::Int=43,
          randomness::Float64 = 1.0,
          output_file = nothing,
  
          # initial values for statement configuration
          delay::Float64 = 0.5,
          julia_delay::Float64 = 0.05,
          char_delay::Float64 = 0.05,
          output_row_delay::Float64 = 0.01,
          output_delay::Float64 = 0.5,
      ) -> String

  Convert a Julia file to a .cast file that can be played by asciinema.
  The return value is a string as the content of the .cast file.

  Keyword Arguments
  –––––––––––––––––––

  The following keyword arguments are for global configurations,

    •  mod is the module to execute the input Julia script.

    •  output_file is the .cast file as output, the default value nothing for not generating a file.

    •  start_delay is time delay before running the first statement.

    •  width and height are the width and height of the terminal.

    •  randomness is the uncertainty in the time delay.

  The following keyword arguments are for the initial statement-wise configurations,

    •  julia_delay is the time delay between julia> and the statement input.

    •  char_delay is the time delay between typing two chars.

    •  output_delay is time delay between the input and the output of a statement.

    •  output_row_delay is time delay between rows of the output of a statement.

    •  delay is time delay after running a statement.

  Examples
  ––––––––––

  julia> using AsciinemaGenerator
  
  julia> output_file = tempname()
  "/tmp/jl_g7aZCDUbC7"
  
  julia> cast_file(joinpath("test/test_input.jl"); output_file, mod=Main);
  
  shell> asciinema play /tmp/jl_g7aZCDUbC7

  The last line plays the clip, please refer the Play section of this docstring.

  Input file
  ––––––––––––

  The statement-wise arguments can also be specify in the input Julia source file. e.g.

  shell> cat test/test_input.jl
  @show "Hello"
  
  using Pkg
  
  #: Waiting for 5 seconds
  #+ 5
  #s delay=1.0; output_row_delay=0.3
  
  println("haa"); Pkg.status()

  Lines starting with #s are for setting parameters, different assign statements should be separated by ;.
  Lines starting with #+ are for inserting an extra time delay. Other lines starting
  with # are regular comments, which will also be shown in the .cast file!

  Play
  ––––––

  To install asciinema, please check the official site (https://asciinema.org/docs/installation).
  One can also deploy the .cast file in a website, please check the demo folder in the demo
  branch of this repo for a minimum Franklin (https://github.com/tlienart/Franklin.jl) static site example.
  ```

## Show case

```julia
julia> using AsciinemaGenerator

julia> cast_file("examples/yao-v0.8.jl"; output_file="examples/yao-v0.8.cast", mod=Main);
```

If we play the generated file with [asciinema](https://asciinema.org/) by typing
```bash
asciinema play examples/yao-v0.8.cast
```
you will see the following video.

[![asciicast](https://asciinema.org/a/3uH0416aRjNMolXXn8Orhl4HH.svg)](https://asciinema.org/a/3uH0416aRjNMolXXn8Orhl4HH)
