import Pkg
using DataViewer
using PackageCompiler

const APP_DIR = @__DIR__
sysimage_path = joinpath(APP_DIR, "dataviewer.so")

packages = Symbol.(keys(Pkg.project().dependencies))
filter!(!=(:PackageCompiler), packages)

@info("Creating system image",
      name = sysimage_path,
      packages)

create_sysimage(
    packages,
    sysimage_path = sysimage_path,
    precompile_execution_file = joinpath(APP_DIR, "precompile.jl"),
)
