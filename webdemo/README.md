Open the `website` folder in a terminal.

## To generate the cast file

```bash
julia --project -e 'cast_file("_assets/scripts/handson.jl";
     output_file="_assets/scripts/yao.cast", mod=Main)'

asciinema play _assets/scripts/yao.cast
```

## To serve

```bash
julia --project -e "using Franklin; serve()"
```