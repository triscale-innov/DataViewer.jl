using DataViewer
using PackageCompiler

const APP_DIR = @__DIR__
sysimage_path = joinpath(APP_DIR, DataViewer.Internal.sysimage_name())

packages = [:DataViewer, :NativeFileDialog, :HDF5, :JLD2, :JSON]

@info("Creating system image",
      name = sysimage_path,
      packages)

create_sysimage(
    packages,
    sysimage_path = sysimage_path,
    precompile_execution_file = joinpath(APP_DIR, "precompile.jl"),
)
