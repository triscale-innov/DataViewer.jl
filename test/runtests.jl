using DataViewer
using Test

using DataViewer: pretty_repr, recurse_into, graphic_repr, get_data, filetype, open_datafile
using DataViewer.Internal: Viewer, script_name, sysimage_name
using DataViewer.Internal.JSServe
using HDF5, JLD2, JSON

function test_representation_options(x, n)
    repr_opts, repr_fun = graphic_repr(x)
    @test length(repr_opts) == n

    if n == 0
        @test repr_fun === nothing
        return
    end

    for opt in repr_opts
        @test opt.icon_name ∈ keys(DataViewer.Internal.ICONS)
        @test repr_fun(opt.param) !== nothing
    end
end

@testset "DataViewer" begin
    DATA = Dict("dict" => Dict(:a => 1, :b => 2),
                "vector" => [1, 2, 3],
                "matrix" => rand(2, 3),
                "array" => rand(2, 3, 4),
                "tuple" => (1,2,3),
                "named_tuple" => (a=1, b=2))

    @testset "get_data" begin
        @test get_data(DATA, ()) === DATA
        @test get_data(DATA, ("dict",  :a)) === DATA["dict"][:a]
        @test get_data(DATA, ("vector", 2)) === DATA["vector"][2]
        @test get_data(DATA, ("matrix", CartesianIndex(1,1))) === DATA["matrix"][1, 1]
    end

    @testset "Viewer" begin
        let v = Viewer(DATA, "my_data")
            @test v((; target="/")) isa JSServe.Node
            @test App(v) isa JSServe.App
        end

        let v = Viewer(DATA, "my_data", (; path=("vector",), method="graph", param=""))
            @test v((; target="/")) isa JSServe.Node
            @test App(v) isa JSServe.App
        end
    end

    @testset "Data representations" begin
        @testset "Named tuple" begin
            let x = DATA["named_tuple"]
                @test pretty_repr(x) == "(a = 1, b = 2)"
                @test recurse_into(x)
                test_representation_options(x, 0)
            end
        end
        @testset "Dict" begin
            let x = DATA["dict"]
                @test pretty_repr(x) == "<2-entry Dict>"
                @test recurse_into(x)
                test_representation_options(x, 1)
            end
        end
        @testset "Vector" begin
            @test pretty_repr(rand(100)) == "<100-element Vector>"
            let x = DATA["vector"]
                @test pretty_repr(x) == "[1, 2, 3]"
                @test recurse_into(x)
                test_representation_options(x, 1)
            end
        end
        @testset "Matrix" begin
            let x = DATA["matrix"]
                @test pretty_repr(x) == "<2×3 Matrix>"
                @test recurse_into(x)
                test_representation_options(x, 2)
            end
        end
        @testset "3D Array" begin
            let x = DATA["array"]
                @test pretty_repr(x) == "<2×3×4  3-D Array>"
                @test recurse_into(x)
                test_representation_options(x, 2)
            end
        end
        @testset "4D Array" begin
            let x = rand(2, 3, 4, 5)
                @test pretty_repr(x) == "<2×3×4×5  4-D Array>"
                @test recurse_into(x)
                test_representation_options(x, 0)
            end
        end
    end

    @testset "File types" begin
        HDF5_Ext = Base.get_extension(DataViewer, :HDF5_Ext)
        JLD2_Ext = Base.get_extension(DataViewer, :JLD2_Ext)
        JSON_Ext = Base.get_extension(DataViewer, :JSON_Ext)

        @test HDF5_Ext isa Module
        @test JLD2_Ext isa Module
        @test JSON_Ext isa Module

        @test filetype("path/to/foo.h5")   == HDF5_Ext.HDF5File
        @test filetype("path/to/foo.hdf")  == HDF5_Ext.HDF5File
        @test filetype("path/to/foo.hdf5") == HDF5_Ext.HDF5File
        @test filetype("path/to/foo.jld2") == JLD2_Ext.JLD2File
        @test filetype("path/to/foo.json") == JSON_Ext.JSONFile

        @test_throws "No known filetype" filetype("foo.txt")
    end

    @testset "Install" begin
        mktempdir() do tmpdir
            ENV["JULIA_PKG_PRECOMPILE_AUTO"] = 0 # No need to precompile everything
            DataViewer.Internal.install(
                destdir  = tmpdir,
                app_dir  = tmpdir,
                command  = "dataviewer",
                force    = false,
                sysimage = false)

            @test ispath(joinpath(tmpdir, "Project.toml"))
            @test ispath(joinpath(tmpdir, "Manifest.toml"))
            @test ispath(joinpath(tmpdir, script_name("dataviewer")))
            @test startswith(sysimage_name(), "sysimage")
        end
    end
end
