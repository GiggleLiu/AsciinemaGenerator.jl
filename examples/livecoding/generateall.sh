#!/bin/bash
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
for FILE in 1.basic  4.multipledispatch 2.array  5.performance  3.types 6.metaprogramming
do
    echo "Generating $FILE..."
    DIR="$BASEDIR/$FILE"
    julia --project="$DIR" -e "using Pkg; Pkg.instantiate()"
    julia --project="$DIR" -e "using AsciinemaGenerator, InteractiveUtils; cast_file(\"$DIR/main.jl\"; output_file=\"$DIR/main.cast\", mod=Main, tada=true, height=30)"
done
