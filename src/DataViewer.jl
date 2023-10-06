module DataViewer

"""
    pretty_repr(x) -> String

Return a pretty textual representation of `x`. By default it is based on `show`,
but can be customized as needed.
"""
function pretty_repr(x)
    io = IOBuffer()
    show(IOContext(io, :compact=>true, :limit=>true), "text/plain", x)
    String(take!(io))
end


````
- `icon_name` identifies a Bootstrap icon
- `label` identifies the graphical representation in the UI
- `method` should generally be "graph" for graphical representations
- when several graphical representations apply, each is identified by its own
  value of `param`
```
struct RepresentationOption
    icon_name :: String
    label     :: String
    method    :: String
    param     :: String
end


"""
    (options, repr) = graphic_repr(x)

If `x` supports one or more graphical representation(s), `options` is a
non-empty `Vector{RepresentationOption}`. In that case, calling
`repr(options[i].param)` should produce the graphical representation
corresponding to the i-th entry in the list.
"""
graphic_repr(::Any) = ([], nothing)


"""
    recurse_into(x) -> Bool

Tells whether `x` is some form of "container" that can be recursed into, or a
"leaf" data.
"""
recurse_into(::Any) = false


"""
    get_data(container, path)

Get the piece of data stored in `container` under `path`.

    get_data(container, (a, b, b))

should be more or less equivalent to

    container[a][b][c]
"""
function get_data end


"""
    filetype(v::Val)

Get the file type associated to the name extension given by `v = Val(Symbol(extension))`.

## Example

```
julia> filetype(Val(Symbol(".jld2")))
JLD2File
```
"""
function filetype(::Val)
    error("No known filetype matches the given extension. "
          * "You may need to load the `JLD2` or `HDF5` packages to handle the relevant data types.")
end


"""
    open_datafile(fun, fname, ftype)

Load the data contained in `fname`, which should be stored using the format
described by `ftype`. Apply `fun` on the loaded data. This function guarantees
that the file stays open as long as needed, but is closed before the function
returns.

## Example

```
julia> ftype = filetype(Val(Symbol(".jld2")))
JLD2File

julia> open_datafile("sample.jld2", ftype) do data
           println(typeof(data))
       end
Dict
"""
function open_datafile end


include("Internal.jl")


"""
    view(data, name = "")

Open a viewer window for `data`, which may be a dictionary, HDF5 file, or
possibly another key=>value based data type.

Optionally, `name` is a `String` indicating where `data` originates from (for
example, a file name).
"""
view(data, name::String = "") = Internal.view(data, name)


"""
    view(fname::String, ftype = "")

Open a viewer window for the data contained in file `fname`. The extension of
`fname` is used to determine how to read it.

Because the file may need to be accessed during the whole browsing session, this
function does not return until the window has been closed, at which point the
data file itself is closed as well.
"""
view(fname::String, ftype::String = "") = Internal.view(fname, ftype)

end
