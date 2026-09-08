#!/bin/bash
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DIR="$BASEDIR/$1"
julia --project="$DIR" -e "using Pkg; Pkg.instantiate()"
julia --project="$DIR" -e "using AsciinemaGenerator, InteractiveUtils; cast_file(\"$DIR/main.jl\"; output_file=\"$DIR/main.cast\", mod=Main, tada=true, height=30)"
read -p "Run? [y/n] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    "$BASEDIR/play.sh" "$1"
fi
