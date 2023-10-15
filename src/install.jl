function sysimage_name()
    ext = if Sys.iswindows()
        "dll"
    elseif Sys.isapple()
        "dylib"
    else
        "so"
    end
    "sysimage.$ext"
end

function script_name(command)
    Sys.iswindows() ? "$command.bat" : "$command"
end

function shell_script(cmd)
    _quot(x) = "'$x'"
    _join(a, b) = "$a \\\n     $b"
    cmd = mapreduce(_quot, _join, cmd)
    """
    #!/bin/bash

    exec $cmd \\
         "\$@"
    """
end

function batch_script(cmd)
    _quot(x) = "\"$x\""
    _join(a, b) = "$a ^\n     $b"
    cmd = mapreduce(_quot, _join, cmd)
    """
    $cmd ^
         %*
    """
end

function make_launcher(julia, app_dir, sysimage, launcher)
    cmd = ["$julia", "--project=$app_dir"]

    if (sysimage)
        img_path = joinpath(app_dir, sysimage_name())
        push!(cmd, "--sysimage=$img_path")
    end

    push!(cmd, joinpath(app_dir, "main.jl"))

    launcher_script = if Sys.iswindows()
        batch_script(cmd)
    else
        shell_script(cmd)
    end

    open(launcher, "w") do f
        println(f, launcher_script)
    end

    let
        # chmod +x
        mode = stat(launcher).mode | 0o111
        chmod(launcher, mode)
    end
end

function install(; command, destdir, force, sysimage,
                 app_dir::String = get_scratch!(DataViewer, "app"))
    julia   = first(Base.julia_cmd())
    pkg_dir = joinpath(@__DIR__, "..")

    if ispath(destdir)
        if !isdir(destdir)
            @error "Destination is not a directory. Refusing to clobber" destdir
            return
        end
    else
        mkpath(destdir)
    end

    launcher = joinpath(destdir, script_name(command))

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
    make_launcher(julia, app_dir, sysimage, launcher)
end
