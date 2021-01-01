# JuliaPlot
My personal script to generate julia- and mandelbrot visualizations.

## Installation
For those who do not have Julia installed, use the official download from [https://julialang.org/downloads](https://julialang.org/downloads/).
Apt sources are unofficial and cause cryptic error messages.

Ensure that the `julia` executable is in your `PATH`. To allow this JuliaPlot package to be loaded, run (colon at end required)

    export JULIA_LOAD_PATH=~/.julia/dev:

Put this line at the end of your `.bash_profile` or equivalent to persist across terminal sessions

From the Julia repl (start by running `julia` in terminal), run `]dev https://github.com/gustaphe/JuliaPlot.jl` (the `]` must be typed on its own, then the rest can be pasted in). This downloads the project and all dependencies, which can take a while.

If you want these in your `PATH`, you can copy `~/.julia/dev/JuliaPlot/resources/generatejuliabackground.jl` and `~/.julia/dev/JuliaPlot/resources/generatejuliabackground.sh` to `~/.local/bin`.

Otherwise simply run `. ~/.julia/dev/JuliaPlot/resources/generatejuliabackground.sh`. The generated image will be placed in `~/Images/Julia` after potentially a few minutes of computation.

## Usage
If you have `julia`, `xrandr`, `feh` and `notify-send` installed, `generatejuliabackground.sh` will (for a two monitor setup), create and apply a background image like the one below.

## Example
![Example background](./resources/Example.svg)
