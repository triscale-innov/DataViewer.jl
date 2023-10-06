# Vendored assets

## Bootstrap stylesheet

The CSS files vendored in [`bootstrap-5.3.1`](bootstrap-5.3.1) come from the
[Bootstrap](https://github.com/twbs/bootstrap) project and are
copyright (c) 2011-2023 The Bootstrap Authors.

## Bootstrap icons

The SVG files vendored in [`bootstrap-icons-1.10.5`](bootstrap-icons-1.10.5)
come from the [Bootstrap Icons](https://github.com/twbs/icons) project and are
copyright (c) 2011-2023 The Bootstrap Authors.

The contents of these SVG files are then used to generate the
[`icons.jl`](../src/icons.jl) file, which `DataViewer` uses to include the
relevant icons. This code generation is performed by the
[`create_icons.jl`](create_icons.jl) script:

```
shell$ julia create_icons.jl
  Activating project at `~/projets/DataViewer.jl/assets`
  No Changes to `~/projets/DataViewer.jl/assets/Project.toml`
  No Changes to `~/projets/DataViewer.jl/assets/Manifest.toml`
┌ Info: Generating julia code for Bootstrap icons
│   input = "/home/francois/projets/DataViewer.jl/assets/bootstrap-icons-1.10.5"
└   output = "/home/francois/projets/DataViewer.jl/assets/../src/icons.jl"
 - bar-chart-line
 - graph-up
 - house-fill
 - list-columns-reverse
```
