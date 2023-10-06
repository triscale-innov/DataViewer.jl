function pretty_repr(x::Vector)
    n = length(x)
    if n < 10 && all(e isa Number for e in x)
        "[" * join((pretty_repr(e) for e in x), ", ") * "]"
    else
        "<$n-element Vector>"
    end
end

function pretty_repr(x::Matrix)
    m, n = size(x)
    "<$m×$n Matrix>"
end

function pretty_repr(x::Array)
    s = join(size(x), "×")
    d = ndims(x)
    "<$s  $d-D Array>"
end

function pretty_repr(x::Dict)
    n = length(keys(x))
    "<$n-entry Dict>"
end



function text_repr(viewer, path, data)
    keys = Base.keys(data)
    messages = []

    N = 1000
    if length(keys) > N
        push!(messages,
              DOM.div("showing only the first $N entries (out of $(length(keys)))",
                      class="alert alert-warning"))
        keys = Iterators.take(keys, N)
    end

    items = map(collect(keys)) do key
        sub_idx = register_path(viewer, (path..., key))
        url = "/text/$sub_idx"
        maybe_link(title) = recurse_into(data[key]) ?
            DOM.a(title, href=url, class="clickable-row") :
            title

        key_dom = DOM.span(replace("⊳ $key", " "=>" "), class="font-monospace, fw-bold")
        data_dom = DOM.span(pretty_repr(data[key]), class="font-monospace")

        DOM.tr(DOM.td(maybe_link(key_dom)),
               DOM.td(maybe_link(data_dom)))
    end

    DOM.div(
        messages...,
        DOM.table(class="table table-hover", items)
    )
end
