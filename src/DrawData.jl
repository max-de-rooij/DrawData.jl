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

    Base.get(c::Canvas) = Vector{Float64, Float64, Int}

    function Base.show(io::IO, m::MIME"text/html", c::Canvas)
        show(io,m,build_canvas(c))
    end

    include("widget.jl")

    export Canvas, build_canvas

end