using PrecompileTools

@setup_workload let
    data = Dict(
        "dict" => Dict("key" => 42),
        "vector" => rand(10),
        "matrix" => rand(5, 5),
        "array" => rand(3, 3, 3),
        "tuple" => (1, 2, 3),
        "named_tuple" => (a = 1, b = 2),
    )
    @compile_workload begin
        for x in values(data)
            pr = pretty_repr(x)
            rec = recurse_into(x)

            repr_opts, repr_fun = graphic_repr(x)
            for opt in repr_opts
                repr_fun(opt.param)
            end
        end
    end
end
