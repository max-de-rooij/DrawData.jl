# DrawData.jl

A Pluto widget for interactively drawing 2D datasets with multiple classes. Inspired by the [`drawdata`](https://github.com/koaning/drawdata) widget.

## Installation

Add `DrawData.jl` to your Julia environment:

```julia
using Pkg
Pkg.add(url="https://github.com/max-de-rooij/DrawData.jl")
```

Or in a Pluto notebook, use the package manager in the top-left corner.

## Basic Usage

### Simple Canvas with Default Settings

The simplest way to use DrawData is to create a canvas with default Julia logo colors:

```julia
using DrawData

@bind points Canvas()
```

This creates a canvas with 4 default classes labeled "1", "2", "3", and "4" using the Julia logo colors.

### Custom Canvas with Your Classes

Create a canvas with custom class names and colors:

```julia
using DrawData
using Colors

custom_colors = [colorant"red", colorant"blue", colorant"green"]
custom_names = ["Class A", "Class B", "Class C"]

@bind points Canvas(colors=custom_colors, names=custom_names)
```
