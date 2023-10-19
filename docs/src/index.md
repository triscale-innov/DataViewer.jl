```@meta
CurrentModule = DataViewer
```

# DataViewer

Documentation for [DataViewer](https://github.com/triscale-innov/DataViewer.jl).

![](screencast.mp4)


## Installation

`DataViewer` is not registered (yet), so you need to provide its full URL to the Julia package manager.

```julia-repl
julia> ] # enter Pkg mode
pkg> add https://github.com/triscale-innov/DataViewer.jl.git
```

Since `DataViewer` requires a lot of heavy dependencies, it is not advised to
add it to the default environment. One possibility would be to create a
dedicated named environment:

```julia-repl
julia> ] # enter Pkg mode
(@v1.9) pkg> activate @dataviewer
(@dataviewer) pkg> add https://github.com/triscale-innov/DataViewer.jl.git
```

## Use as a Julia package

`DataViewer` can be used as a regular package from inside a Julia REPL. Whenever
there is some data structure that you want to explore, call the [`view`](@ref) function:
```julia-repl
julia> using JLD2

julia> data = JLD2.load("sample.jld2");

julia> using DataViewer
[ Info: Precompiling DataViewer [69fa7e04-3a55-42d6-bb08-3ca48704fbef]
[ Info: Precompiling JSON_Ext [056fc32c-03f3-5092-ad64-0a1590c5cd8d]
[ Info: Precompiling JLD2_Ext [ab4143e6-3402-5971-8428-17ae5f4067b4]

julia> DataViewer.view(data)
```

It is also possible to directly call [`view`](@ref) on a file name:
```julia-repl
julia> using HDF5
[ Info: Precompiling HDF5_Ext [c89765bd-c6f5-5c69-b5b2-135d132d13bc]

julia> DataViewer.view("sample.h5")
```

!!! note

    In this case, you'll need to first load the appropriate package for the file
    format you want to read: `HDF5`, `JLD2` or `JSON`.

## Use as a standalone application

After having installed the `DataViewer` package, you can ask it to
[`install`](@ref) a standalone application, callable from the command-line:

```julia-repl
julia> using DataViewer

julia> DataViewer.install()
```

By default, a launcher named `dataviewer` will be placed in the `~/.julia/bin`
directory, which you should add to your `PATH` environment variable. Afterwards,
you can run this new command from a shell.

!!! note

    Windows users may want to run something like:
    
    ```
    julia> DataViewer.install(destdir = joinpath(homedir(), "Desktop"))
    ```
    
    in order to put the launcher on their desktop.

Without argument, a file picker window will pop up to ask for a file to open:
```shell
$ dataviewer
```

With one argument, the given file will be viewed:
```shell
$ dataviewer sample.hdf5
```

A second argument allows specifying the file type if the extension is not enough
to guess it. This optional argument may be either the name of the relevant Julia
package (*e.g* `JSON`) or a file extension associated to the file format (*e.g* `.json`):
```shell
$ dataviewer sample JSON
```
