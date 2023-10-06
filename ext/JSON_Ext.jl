module JSON_Ext

import DataViewer as DV
import JSON

struct JSONFile end

function DV.open_datafile(fun, fname, ::Type{JSONFile})
    tighten!(x) = x

    function tighten!(d::Dict)
        for key in keys(d)
            d[key] = tighten!(d[key])
        end
        return d
    end

    function tighten!(x::Vector)
        isempty(x) && return x

        x = tighten!.(x)
        eltype(x) <: Array || return x
        all(size(e)==size(first(x)) for e in x) || return x
        stack(x)
    end

    data = tighten!(JSON.parsefile(fname))
    fun(data)
end

DV.filetype(::Val{Symbol("JSON")})  = JSONFile
DV.filetype(::Val{Symbol(".json")}) = JSONFile

end
