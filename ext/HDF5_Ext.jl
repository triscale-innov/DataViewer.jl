module HDF5_Ext

import DataViewer as DV
import HDF5

struct HDF5File end

DV.open_datafile(fun, fname, ::Type{HDF5File}) = HDF5.h5open(fun, fname, "r")

DV.filetype(::Val{Symbol("HDF5")})  = HDF5File
DV.filetype(::Val{Symbol(".h5")})   = HDF5File
DV.filetype(::Val{Symbol(".hdf")})  = HDF5File
DV.filetype(::Val{Symbol(".hdf5")}) = HDF5File


function DV.get_data(f::HDF5.File, path)
    gd(d::HDF5.Dataset, ::Tuple{}) = read(d)
    gd(f, ::Tuple{}) = f
    gd(f, path) = gd(f[first(path)], Base.tail(path))
    gd(f, path)
end


DV.recurse_into(::HDF5.Group) = true
DV.recurse_into(x::HDF5.Dataset) = DV.recurse_into(read(x))

DV.pretty_repr(g::HDF5.Group) = "<$(length(g))-element HDF5 Group>"
DV.pretty_repr(x::HDF5.Dataset) = DV.pretty_repr(read(x))

end
