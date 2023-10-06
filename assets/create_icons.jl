import Pkg
Pkg.activate(@__DIR__)
Pkg.resolve()

using XML

const ICONS_ROOT = joinpath(@__DIR__, "bootstrap-icons-1.10.5")
const ICONS_FILE = joinpath(@__DIR__, "..", "src", "icons.jl")
const NOTICE = """#=

    This file was automatically generated from icons distributed in the
    "Bootstrap icons" project (https://github.com/twbs/icons).

    See `assets/create_icons.jl`

=#"""
icon_file(name) = joinpath(ICONS_ROOT, "$name.svg")

function to_expr(node)
    t = tag(node)
    attrs = attributes(node)
    expr = :(Hyperscript.m($t))
    for (k, v) in attrs
        push!(expr.args, Expr(:kw, Symbol(k), v))
    end
    for child in children(node)
        push!(expr.args, to_expr(child))
    end

    expr
end

function to_expr(icon_name::String, path::String)
    doc = read(path, Node)
    :(ICONS[$icon_name] = $(to_expr(doc[end])))
end

@info("Generating julia code for Bootstrap icons",
      input = ICONS_ROOT,
      output = ICONS_FILE)

open(ICONS_FILE, "w") do f
    println(f, NOTICE)
    println(f, :(ICONS = Dict("__unused__"=>Hyperscript.m("svg"))))

    for fname in readdir(ICONS_ROOT)
        (icon_name, ext) = splitext(fname)
        ext == ".svg" || continue
        println(" - $icon_name")
        println(f, to_expr(icon_name, joinpath(ICONS_ROOT, fname)))
    end
end
