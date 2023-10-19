# DataViewer

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://triscale-innov.github.io/DataViewer.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://triscale-innov.github.io/DataViewer.jl/dev/)
[![Build Status](https://github.com/triscale-innov/DataViewer.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/triscale-innov/DataViewer.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/triscale-innov/DataViewer.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/triscale-innov/DataViewer.jl)

**Explore your data files with the power of [Makie](https://docs.makie.org/stable/)!**

https://github.com/triscale-innov/DataViewer.jl/assets/376712/bffabeef-c5cd-41b5-bcf0-7f6757042fec

## Use as a Julia package

`DataViewer` is not registered (yet), so you need to provide its full URL to the Julia package manager.

```julia-repl
julia> ] # enter Pkg mode
pkg> add https://github.com/triscale-innov/DataViewer.jl.git
```

Then, whenever there is some data structure that you want to explore:
```julia-repl
julia> using JLD2

julia> data = JLD2.load("sample.jld2");

julia> using DataViewer
[ Info: Precompiling DataViewer [69fa7e04-3a55-42d6-bb08-3ca48704fbef]
[ Info: Precompiling JSON_Ext [056fc32c-03f3-5092-ad64-0a1590c5cd8d]
[ Info: Precompiling JLD2_Ext [ab4143e6-3402-5971-8428-17ae5f4067b4]

julia> DataViewer.view(data)
```

It is also possible to directly call `DataViewer.view` on a file name:
```julia-repl
julia> using HDF5
[ Info: Precompiling HDF5_Ext [c89765bd-c6f5-5c69-b5b2-135d132d13bc]

julia> DataViewer.view("sample.h5")
```

## Use as a standalone application

After having installed the `DataViewer` package, you can ask it to install a standalone application, callable from the command-line:

```julia-repl
julia> using DataViewer

julia> DataViewer.install()
```

By default, a launcher named `dataviewer` will be placed in the `~/.julia/bin` directory, which you should add to your `PATH` environment variable. Afterwards, you can run this new command from a shell.

Without argument, a file picker window will pop up to ask for a file to open:
```shell
$ dataviewer
```

With one argument, the given file will be viewed:
```shell
$ dataviewer sample.hdf5
```

A second argument allows specifying the file type if the extension is not enough to guess it:
```shell
$ dataviewer sample JSON
```
