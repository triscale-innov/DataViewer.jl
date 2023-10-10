module Internal

using Electron
using JSServe
using WGLMakie
using HTTP.URIs
using Scratch

import DataViewer
import DataViewer: pretty_repr, graphic_repr, recurse_into, get_data, filetype, open_datafile

include("datatypes.jl")
include("text_repr.jl")
include("graphic_repr.jl")

include("viewer.jl")
include("install.jl")

function view(data, name::String; target=nothing)
    WGLMakie.activate!()

    viewer = Viewer(data, name, target)
    app = App(viewer)

    server = JSServe.get_server()
    route!(server, r"^/text/" => app)
    route!(server, r"^/graph/" => app)
    route!(server, "/" => app)

    electron_display = JSServe.use_electron_display()
    display(app)
    sleep(1)
    win = electron_display.window
    Electron.toggle_devtools(win)
    return win
end

function view(fname::String, ftype::String)
    if ftype == ""
        ftype = filetype(fname)
    else
        ftype = filetype(Val(Symbol(ftype)))
    end

    open_datafile(fname, ftype) do data
        win = view(data, basename(fname))
        try
            take!(msgchannel(win))
        catch e
            if e isa InvalidStateException
                @info "Window was closed"
                return
            else
                rethrow()
            end
        end
        sleep(1)
    end
end

end #module
