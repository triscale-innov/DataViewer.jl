using DataViewer: RepresentationOption

function graphic_repr(x::Vector{T}) where {T <: Number}
    options = [RepresentationOption("graph-up", "plot", "graph", "")]
    repr = (_) -> begin
        fig, _, _ = scatter(x)
        return DOM.div(fig)
    end
    (options, repr)
end

function graphic_repr(x::Matrix{T}) where {T <: Number}
    options = [RepresentationOption("graph-up", "surface", "graph", "surface")
               RepresentationOption("graph-up", "heatmap", "graph", "heatmap")]
    repr = (param) -> begin
        fig = Figure()

        if param == "surface"
            ax = Axis3(fig[1,1])
            surface!(ax, x, colormap=:bluesreds)
        else
            ax = Axis(fig[1,1], aspect=1)
            heatmap!(ax, x, colormap=:bluesreds)
        end

        return DOM.div(fig)
    end
    (options, repr)
end

function graphic_repr(x::Array{T, 3}) where {T <: Number}
    options = [RepresentationOption("graph-up", "volume slices", "graph", "volumeslices"),
               RepresentationOption("graph-up", "contour",       "graph", "contour"),]
    repr = (param) -> if param == "contour"
        (m, n, p) = size(x)
        slider = Slider(1:p)

        fig = Figure()
        ax, _ = contour(fig[1,1], x, colormap=:bluesreds)

        cut = linesegments!(ax, Rect(-1, -1, m+1, n+1), linewidth=2, color=:red)
        on(slider) do k
            translate!(cut, 0,0,k)
        end

        slice = map(slider) do k
            return x[:,:,k]
        end
        ax, hm = heatmap(fig[1,2][1,1], slice,
                         colormap=:bluesreds,
                         colorrange=extrema(x))
        ax.aspect = 1

        Colorbar(fig[1,2][1,2], hm)

        slider[] = p÷2
        return DOM.div(
            DOM.div("z-cut: ", slider, slider.value),
            fig)
    else
        (m, n, p) = size(x)
        fig = Figure()

        # Volume slices
        ax = LScene(fig[1, 1][1, 1], show_axis=false)
        plt = volumeslices!(ax, 1:m, 1:n, 1:p, x,
                            colormap=:bluesreds)
        Colorbar(fig[1, 1][1, 2], plt)

        # Sliders
        sgrid = SliderGrid(
            fig[2, 1],
            (label = "yz plane - x axis", range = 1:m),
            (label = "xz plane - y axis", range = 1:n),
            (label = "xy plane - z axis", range = 1:p),
        )
        sl_yz, sl_xz, sl_xy = sgrid.sliders
        on(sl_yz.value) do v; plt[:update_yz][](v) end
        on(sl_xz.value) do v; plt[:update_xz][](v) end
        on(sl_xy.value) do v; plt[:update_xy][](v) end

        set_close_to!(sl_yz, m÷2)
        set_close_to!(sl_xz, n÷2)
        set_close_to!(sl_xy, p÷2)

        # # Toggles to show/hide heatmaps
        # lo = sgrid.layout
        # nc = ncols(lo)
        # hmaps = [plt[Symbol(:heatmap_, s)][] for s ∈ (:yz, :xz, :xy)]
        # toggles = [Toggle(lo[i, nc + 1], active = true) for i ∈ 1:length(hmaps)]

        # map(zip(hmaps, toggles)) do (h, t)
        #     connect!(h.visible, t.active)
        # end

        return DOM.div(fig)
    end
    (options, repr)
end

function graphic_repr(d::Dict{KEY,VAL}) where {KEY, VAL<:Number}
    options = [RepresentationOption("bar-chart-line", "bar chart", "graph", "")]
    repr = (_) -> begin
        x = Int[]
        ticks = String[]
        y = VAL[]
        for (i, k) in enumerate(keys(d))
            push!(x, i)
            push!(y, d[k])
            push!(ticks, "$k")
        end
        fig, _, _ = barplot(x, y, axis=(;xticks = (x, ticks)))
        return DOM.div(fig)
    end
    (options, repr)
end
