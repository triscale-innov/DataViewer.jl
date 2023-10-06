
const CSS = Asset(joinpath(@__DIR__, "..", "assets", "style.css"))
const BOOTSTRAP = Asset(joinpath(@__DIR__, "..", "assets", "bootstrap-5.3.1", "bootstrap-5.3.1.css"))

using JSServe.Hyperscript
include("icons.jl")

struct Viewer
    data :: Any
    name :: String
    path :: Vector{Any}
    default_uri :: String
    function Viewer(data, name, target=nothing)
        target = something(target, (; path=(), method="text", param=""))
        path = [target.path]
        default_uri = "/$(target.method)/1?$(target.param)"
        new(data, name, path, default_uri)
    end
end

function (viewer::Viewer)(request)
    # Forward "/" to default uri
    target = request.target
    if target == "/"
        target = viewer.default_uri
    end

    # Parse request
    uri = URI(target)
    components = split(uri.path, "/")

    method = components[2]

    idx = parse(Int, components[3])
    path = viewer.path[idx]
    sub_data = get_data(viewer, path)

    param = uri.query

    @info "Processing request" target method path param

    # Breadcrumbs
    breadcrumbs = let
        items = map(0:length(path)) do i
            title = i==0 ? DOM.span(ICONS["house-fill"], viewer.name=="" ? "" : " ", viewer.name) : "$(path[i])"
            subpath = path[1:i]
            sub_idx = register_path(viewer, subpath)
            DOM.li(class="breadcrumb-item",
                   DOM.a(title,
                         href="/text/$sub_idx"))
        end
        DOM.nav(
            class="font-monospace",
            DOM.ol(class="breadcrumb",
                   items...))
    end

    # Button bar
    repr_opts, repr_fun = graphic_repr(sub_data)
    button_bar = let
        pushfirst!(repr_opts, RepresentationOption("list-columns-reverse", "text", "text", ""))

        items = map(repr_opts) do opt
            if opt.method == method && opt.param == param
                class = "btn-primary disabled"
            else
                class = "btn-outline-primary"
            end
            url = "/$(opt.method)/$idx?$(opt.param)"
            DOM.a(href = url,
                  class = "btn $class",
                  ICONS[opt.icon_name], " $(opt.label)")
        end
        length(items) == 1 && empty!(items)
        DOM.div(class="button-bar", items...)
    end

    # Main contents
    contents = if method == "text"
        text_repr(viewer, path, sub_data)
    elseif method == "graph"
        repr_fun(param)
    end

    # Whole page
    DOM.html(
        DOM.head(
            DOM.meta(charset="utf-8"),
            DOM.title("DataViewer" * (viewer.name == "" ? "" : " - ") * viewer.name),
            BOOTSTRAP, CSS,
        ),
        DOM.body(
            DOM.div(
                class = "container-lg",
                style = "padding-top: 1em;",
                DOM.div(
                    style = "padding-top: 6em;",
                    contents,
                ),
                DOM.div(
                    class = "position-absolute top-0",
                    style = "padding-top: 1em; width: 100%;",
                    breadcrumbs,
                    button_bar,
                ),
            )
        )
    )
end

get_data(viewer::Viewer, path)  = get_data(viewer.data, path)

function register_path(viewer, path)
    i = findfirst(==(path), viewer.path)
    if i === nothing
        push!(viewer.path, path)
        i = lastindex(viewer.path)
    end
    return i
end

JSServe.App(viewer::Viewer) = App((_,r)->viewer(r))
