using Scratch
using DataViewer

const JULIA   = first(Base.julia_cmd())
const PKG_DIR = joinpath(@__DIR__, "..")
const APP_DIR = get_scratch!(DataViewer, "app")
const BIN_DIR = joinpath(Base.DEPOT_PATH[1], "bin")

function make_executable(fname)
    mode = stat(fname).mode | 0o111
    chmod(fname, mode)
end

cd(APP_DIR) do
    @info "Copying files"
    for fname in ("Project.toml", "make.jl", "main.jl", "precompile.jl", "create_samples.jl")
        cp(joinpath(PKG_DIR, "app", fname), fname, force=true)
    end

    @info "Installing app environment"
    script = quote
        import Pkg
        Pkg.develop(path=$PKG_DIR)
        Pkg.resolve()
        Pkg.instantiate()
    end
    run(`$JULIA --project -e $script`)

    @info "Creating data samples"
    run(`$JULIA --project create_samples.jl`)

    @info "Building app"
    run(`$JULIA --project make.jl`)

    @info "Cleaning up"
    foreach(f -> rm(f, force=true),
            ["make.jl", "precompile.jl", "create_samples.jl",
             "sample.h5", "sample.jld2", "sample.json"])

    launcher = joinpath(BIN_DIR, "dataviewer")
    @info "Installing launcher script" target=launcher
    launcher_script = let
        sysimage = joinpath(APP_DIR, "dataviewer.so")
        main = joinpath(APP_DIR, "main.jl")
        """
        #!/bin/bash

        exec "$JULIA" \\
             --project="$APP_DIR" \\
             --sysimage="$sysimage" \\
             "$main" \\
             "\$@"
        """
    end
    open(launcher, "w") do f
        println(f, launcher_script)
    end
    make_executable(launcher)
end
