module JLD2_Ext

import DataViewer as DV
import JLD2

struct JLD2File end

DV.open_datafile(fun, fname, ::Type{JLD2File}) = fun(JLD2.load(fname))

DV.filetype(::Val{Symbol("JLD2")})  = JLD2File
DV.filetype(::Val{Symbol(".jld2")}) = JLD2File

end
