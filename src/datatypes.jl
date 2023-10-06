recurse_into(::Dict) = true
recurse_into(::AbstractArray) = true
recurse_into(::NamedTuple) = true


function get_data(dict::Dict, path)
    gd(dict, ::Tuple{}) = dict
    gd(dict, path)      = gd(dict[first(path)], Base.tail(path))
    gd(dict, path)
end


"""
    filetype(fname::String)

Get the file type associated to a file named `fname`, according to its extension.
"""
function filetype(fname::String)
    (_, ext) = splitext(fname)
    filetype(Val(Symbol(ext)))
end
