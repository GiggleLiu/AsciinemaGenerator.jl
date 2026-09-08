#!/usr/bin/env bash
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DIR="$BASEDIR/$1"
shift
asciinema play "$DIR/main.cast" "$@"
echo "DONE"
