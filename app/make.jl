include("setup.jl")
using DataViewer
using PackageCompiler


packages = Symbol.(keys(Pkg.project().dependencies))
filter!(!=(:PackageCompiler), packages)

sysimage_path = joinpath(@__DIR__, "dataviewer.so")

@info("Creating system image",
      name = sysimage_path,
      packages)

create_sysimage(
    packages,
    sysimage_path = sysimage_path,
    precompile_execution_file = joinpath(@__DIR__, "precompile.jl"),

    # Optional: generate a "portable" sysimage on x86-64 architectures
    cpu_target = "generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)",
)
