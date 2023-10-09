using DataViewer, HDF5, JLD2, JSON
using DataViewer: recurse_into, pretty_repr, graphic_repr, open_datafile, RepresentationOption

function view(data, name; target=nothing)
    win = DataViewer.Internal.view(data, name; target)
    sleep(2)
    close(win)
end

view(name) = data -> view(data, name)

HDF5_Ext = Base.get_extension(DataViewer, :HDF5_Ext)
JLD2_Ext = Base.get_extension(DataViewer, :JLD2_Ext)
JSON_Ext = Base.get_extension(DataViewer, :JSON_Ext)

@info "Load HDF5 data"
open_datafile(view("sample.h5"), joinpath(@__DIR__, "sample.h5"), HDF5_Ext.HDF5File)

@info "Load JLD2 data"
open_datafile(view("sample.jld2"), joinpath(@__DIR__, "sample.jld2"), JLD2_Ext.JLD2File)

@info "Load JSON data"
open_datafile(view("sample.json"), joinpath(@__DIR__, "sample.json"), JSON_Ext.JSONFile)

let
    data = JLD2.load(joinpath(@__DIR__, "sample.jld2"))
    for k in keys(data)
        x = data[k]
        pr = pretty_repr(x)
        rec = recurse_into(x)

        repr_opts, _ = graphic_repr(x)
        @info("Viewing data field",
              T=typeof(x),
              pretty_repr=pr,
              recurse_into=rec,
              graphic_representations=Tuple(opt.label for opt in repr_opts))

        rec || continue

        pushfirst!(repr_opts, RepresentationOption("<ICON>", "<TEXT>", "text", ""))
        for (; method, param) in repr_opts
            path = (k,)
            target = (; path, method, param)
            view(data, "sample.jld2"; target)
        end
    end
end
