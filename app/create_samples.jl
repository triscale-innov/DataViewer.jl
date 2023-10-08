include("setup.jl")
using DataView.JLD2
using DataView.HDF5
using DataView.JSON

data = let t=0:0.02:2π
    Dict(
        "string" => "Hello",
        "tuple" => (1, 2, 3),
        "named_tuple" => (a=1, b=2, c=3),
        "vector" => sin.(t),
        "matrix" => [sin(x)*cos(y) for x in t, y in t],
        "3D array" => [sin(x)*cos(y)*cos(z) for x in t, y in t, z in t],
        "dict" => Dict(
            "apples" => 10,
            "oranges" => 11,
            "bananas" => 12,
        ),
        "deep" => Dict(
            "deeper" => (a=1, b=2, c=3)
        )
    )
end

let fname = joinpath(@__DIR__, "sample.jld2")
    @info "Saving JLD2 sample" fname
    JLD2.save(fname, data)
end

let fname = joinpath(@__DIR__, "sample.h5")
    @info "Saving HDF5 sample" fname
    h5open(fname, "w") do datafile
        for key in ("string", "vector", "matrix", "3D array")
            datafile[key] = data[key]
        end

        create_group(datafile, "dict")
        for key in keys(data["dict"])
            datafile["dict"][key] = data["dict"][key]
        end

        create_group(datafile, "deep")
        datafile["deep"]["deeper"] = [1, 2, 3]
    end
end

let fname = joinpath(@__DIR__, "sample.json")
    @info "Saving JSON sample" fname
    open(fname, "w") do datafile
        JSON.print(datafile, data)
    end
end
