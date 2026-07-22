using Test
using DrawData
using Colors
using HypertextLiteral

@testset "Canvas Struct Tests" begin
    @testset "Default Canvas Construction" begin
        canvas = Canvas()
        
        # Check that default colors are set (Julia logo colors)
        @test length(canvas.colors) == 4
        @test length(canvas.names) == 4
        @test canvas.names == ["1", "2", "3", "4"]
        
        # Verify default colors are Julia logo colors
        default_colors = collect(values(Colors.JULIA_LOGO_COLORS))
        @test canvas.colors == default_colors
    end
    
    @testset "Custom Canvas Construction" begin
        custom_colors = [colorant"red", colorant"blue", colorant"green"]
        custom_names = ["Red", "Blue", "Green"]
        
        canvas = Canvas(colors=custom_colors, names=custom_names)
        
        @test canvas.colors == custom_colors
        @test canvas.names == custom_names
        @test length(canvas.colors) == 3
        @test length(canvas.names) == 3
    end
    
    @testset "Canvas with Single Class" begin
        canvas = Canvas(colors=[colorant"red"], names=["Single"])
        
        @test length(canvas.colors) == 1
        @test length(canvas.names) == 1
        @test canvas.names[1] == "Single"
    end
    
    @testset "Canvas with Two Classes" begin
        canvas = Canvas(colors=[colorant"red", colorant"blue"], names=["A", "B"])
        
        @test length(canvas.colors) == 2
        @test length(canvas.names) == 2
    end
end

@testset "Build Canvas HTML Tests" begin
    @testset "Default Canvas Generates HTML" begin
        canvas = Canvas()
        html_output = DrawData.build_canvas(canvas)
        
        # Check that output is not empty
        @test html_output !== nothing
        
        # Convert to string to check for expected elements
        html_str = string(html_output)
        
        @test contains(html_str, "drawdata-widget")
        @test contains(html_str, "canvas")
        @test contains(html_str, "toolbar")
        @test contains(html_str, "class-option")
        @test contains(html_str, "reset-button")
        @test contains(html_str, "download-button")
        @test contains(html_str, "size-slider")
    end
    
    @testset "Custom Canvas HTML Contains Custom Names" begin
        custom_names = ["Class_A", "Class_B", "Class_C"]
        canvas = Canvas(
            colors=[colorant"red", colorant"blue", colorant"green"],
            names=custom_names
        )
        html_output = DrawData.build_canvas(canvas)
        html_str = string(html_output)
        
        # All custom names should appear in the HTML
        for name in custom_names
            @test contains(html_str, name)
        end
    end
    
    @testset "Canvas HTML Includes JavaScript" begin
        canvas = Canvas()
        html_output = DrawData.build_canvas(canvas)
        html_str = string(html_output)
        
        # Check for JavaScript elements
        @test contains(html_str, "script")
        @test contains(html_str, "currentScript")
    end
    
    @testset "Canvas HTML Includes Radio Buttons" begin
        canvas = Canvas()
        html_output = DrawData.build_canvas(canvas)
        html_str = string(html_output)
        
        # Check for radio button elements
        @test contains(html_str, "radio")
        @test contains(html_str, "active-class")
    end
    
    @testset "Canvas with Single Class HTML" begin
        canvas = Canvas(colors=[colorant"red"], names=["OnlyOne"])
        html_output = DrawData.build_canvas(canvas)
        html_str = string(html_output)
        
        @test contains(html_str, "OnlyOne")
        @test contains(html_str, "canvas")
    end
end

@testset "Canvas Type Tests" begin
    @testset "Canvas is Properly Typed" begin
        canvas = Canvas()
        
        @test isa(canvas, DrawData.Canvas)
        @test isa(canvas.colors, AbstractVector)
        @test isa(canvas.names, AbstractVector)
    end
    
    @testset "Colors are Color Type" begin
        canvas = Canvas()
        
        # All colors should be Color objects
        for color in canvas.colors
            @test isa(color, Colorant)
        end
    end
    
    @testset "Names are String Type" begin
        canvas = Canvas()
        
        # All names should be strings
        for name in canvas.names
            @test isa(name, String)
        end
    end
end

@testset "Edge Cases" begin
    @testset "Empty Names Converted to String" begin
        canvas = Canvas(colors=[colorant"red"], names=[""])
        
        @test canvas.names[1] == ""
        @test isa(canvas.names[1], String)
    end
    
    @testset "Maximum 4 Classes Works" begin
        canvas = Canvas(
            colors=[colorant"red", colorant"blue", colorant"green", colorant"yellow"],
            names=["1", "2", "3", "4"]
        )
        
        @test length(canvas.colors) == 4
        @test length(canvas.names) == 4
    end
    
    @testset "Colors Vector Length Preservation" begin
        # Canvas should preserve the exact colors provided
        colors = [colorant"red", colorant"blue"]
        canvas = Canvas(colors=colors, names=["A", "B"])
        
        @test canvas.colors === colors || canvas.colors == colors
    end
end
