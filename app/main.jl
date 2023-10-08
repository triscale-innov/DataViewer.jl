import Pkg
Pkg.activate(@__DIR__; io=devnull)
import DataViewer
import HDF5, JLD2, JSON

fname = get(ARGS, 1, "")
ftype = get(ARGS, 2, "")

if fname == ""
    import NativeFileDialog
    fname = NativeFileDialog.pick_file(pwd())
end

if fname == ""
    exit(0)
end

DataViewer.view(fname, ftype)
