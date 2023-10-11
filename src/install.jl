function install(; command, destdir, force, sysimage,
                 app_dir::String = get_scratch!(DataViewer, "app"))
    julia   = first(Base.julia_cmd())
    pkg_dir = joinpath(@__DIR__, "..")

    launcher = joinpath(destdir, command)

    if ispath(launcher)
        if force
            @warn "Overwriting existing installation" launcher=launcher
        else
            @error "Found existing installation. Pass `force=true` to overwrite." launcher=launcher
            return
        end
    end

    @info("Installing DataViewer launcher",
          julia = julia,
          app_dir = app_dir,
          pkg_dir = pkg_dir,
          launcher = launcher)

    cd(app_dir) do
        @info "Copying files"
        for fname in ("Project.toml", "make.jl", "main.jl", "precompile.jl", "create_samples.jl")
            cp(joinpath(pkg_dir, "app", fname), fname, force=true)
        end
        rm("Manifest.toml", force=true)

        @info "Installing app environment"
        script = quote
            import Pkg
            Pkg.develop(path=$pkg_dir)
            Pkg.instantiate()
        end
        run(`$julia --project -e $script`)

        if sysimage
            @info "Creating data samples"
            run(`$julia --project create_samples.jl`)

            @info "Building app"
            run(`$julia --project make.jl`)
        end

        @info "Cleaning up"
        foreach(f -> rm(f, force=true),
                ["make.jl", "precompile.jl", "create_samples.jl",
                 "sample.h5", "sample.jld2", "sample.json"])
    end

    @info "Installing launcher script" target=launcher
    launcher_script = let
        cmd = ["$julia"]

        push!(cmd, "--project=$app_dir")

        if (sysimage)
            img_path = joinpath(app_dir, "dataviewer.so")
            push!(cmd, "--sysimage=$img_path")
        end

        push!(cmd, joinpath(app_dir, "main.jl"))

        map!(cmd, cmd) do arg
            "'$arg'"
        end
        cmd = join(cmd, " \\\n     ")

        """
        #!/bin/bash

        exec $cmd \\
             "\$@"
        """
    end
    open(launcher, "w") do f
        println(f, launcher_script)
    end

    function make_executable(fname)
        mode = stat(fname).mode | 0o111
        chmod(fname, mode)
    end
    make_executable(launcher)
end
