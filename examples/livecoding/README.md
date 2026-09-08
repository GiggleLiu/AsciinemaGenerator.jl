## Generate cast files

These Julia tutorial recordings were moved from
[`GiggleLiu/notebooks`](https://github.com/GiggleLiu/notebooks/tree/julia-tutorial/livecoding)
at commit [`03b44b8`](https://github.com/GiggleLiu/notebooks/commit/03b44b8f22b0c2b7523189aa5f5aa6d165545f5b).
Each subdirectory keeps its original project environment. The `yao` example uses
`CuYao` and requires a working CUDA-capable setup for its GPU section.

```bash
./generate.sh matmul

./play.sh matmul  # the asciinema must be installed!
```
