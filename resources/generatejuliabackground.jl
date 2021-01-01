#! /bin/julia
# ~/.julia/dev/JuliaPlot/src/JuliaPlot.jl
using JuliaPlot
posstrings=readlines(`xrandr --listmonitors`)
pos = Tuple(
            parse.(Int64,
                   getindex.(
                             Ref(match(r".* (\d+)/\d+x(\d+)/\d+\+(\d+)\+(\d+) .*",posstring))
                             ,(3,4,1,2)
                            )
                  )
            for posstring in posstrings[2:end]
           )
multiMonitorJuliaPlot(;
                      pos = pos,
                     )
