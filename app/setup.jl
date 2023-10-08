using Pkg
cd(@__DIR__)
Pkg.activate(".")
Pkg.develop(path="..")
Pkg.resolve()
Pkg.instantiate()
