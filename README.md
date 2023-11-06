# AsciinemaGenerator

[![Build Status](https://github.com/GiggleLiu/AsciinemaGenerator.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GiggleLiu/AsciinemaGenerator.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/GiggleLiu/AsciinemaGenerator.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/GiggleLiu/AsciinemaGenerator.jl)

This package mainly provides a single function `cast_file` that generates a `.cast` file from your Julia source code.

## Install
Type `using Pkg; Pkg.add("https://github.com/GiggleLiu/AsciinemaGenerator.jl.git")` in a Julia REPL to install this package.

## Usage
1. Prepare a Julia source file, e.g. [examples/yao/yao-v0.8.jl](examples/yao/yao-v0.8.jl). Please check the [Source file Syntax](#source-file-syntax) section for the supported syntax.
2. Run the following code in a Julia REPL:
   ```julia
   julia> using AsciinemaGenerator
   #  Please type `?cast_file` to get help on configurable parameters.
   julia> cast_file("examples/yao/yao-v0.8.jl";
        output_file="examples/yao/yao-v0.8.cast"
    );
   ```
   The generated `.cast` file is [examples/yao/yao-v0.8.cast](examples/yao/yao-v0.8.cast).
   *Please make sure the required packages are installed in the current environment.*
3. Preview the generated `.cast` file by either
   1. locally: install python package `asciinema` with: `pip install asciinema` and type `asciinema play <path-to-cast-file>` in a terminal, or
   2. over web: upload your cast file to the public domain, e.g. the GitHub, then open the url: https://giggleliu.github.io/AsciinemaGenerator.jl?target=url-to-cast-file (replace the `url-to-cast-file` with your own cast file url).

## Show case: The Yao Tutorial
https://giggleliu.github.io/AsciinemaGenerator.jl/?target=https://raw.githubusercontent.com/GiggleLiu/YaoTutorial/munich/clips/yao-v0.8.cast

## Source file syntax
We use comments to control the play speed.
1. Wait for a certain time: `#+ int` (space required). The following example will wait for 5 seconds before executing the next line.
    ```julia
    #+ 5
    ```

2. Change settings: `#s key1=value1; key2=value2; ...` (space required). The following example will set the delay to 1 second and the output row delay to 0.3 second. Please check `?cast_file` for the supported settings.
    ```julia
    #s delay=1.0; output_row_delay=0.3
    ```

## Contributing
Contributions are welcome! Please open an issue or a pull request if you have any suggestions or find any bugs.