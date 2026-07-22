module DrawData

    using AbstractPlutoDingetjes, HypertextLiteral
    using Colors
    import Base

    struct Canvas
		colors::AbstractVector
		names::AbstractVector
	end

	function Canvas(;colors=collect(values(Colors.JULIA_LOGO_COLORS)), names=["1", "2", "3", "4"])
	    return Canvas(colors, names)
	end

    function AbstractPlutoDingetjes.Bonds.initial_value(c::Canvas)
        Tuple{Float64, Float64, Int}[]
    end

    function AbstractPlutoDingetjes.Bonds.transform_value(c::Canvas, value)
        [(z[1], z[2], z[3]) for z in value]
    end

    function Base.show(io::IO, m::MIME"text/html", c::Canvas)
        show(io,m,build_canvas(c))
    end

    include("widget.jl")

    export Canvas, build_canvas

end