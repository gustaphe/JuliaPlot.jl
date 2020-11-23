module JuliaPlot
using Plots, Latexify, LaTeXStrings, Printf, Polynomials, Measures

export juliaPlot,mandelbrotPlot,plotBoth,moreLikelyToBeInterestingPlot,julianimation,juliaMatrix,mandelbrotMatrix

function juliaPlot(
                   ;
                   c::Complex = complex(0.6,0.7), # function offset
                   res::Integer = 200, # x resolution
                   R::Float64 = 2.0, # Escape radius
                   aleph::Float64 = 0.8, # Proportion of escape radius to draw
                   I::Integer = 100, # maximum iteration number
                   f::AbstractVector = [0.0,0.0,1.0], # function to iterate
                   size::Tuple{Integer,Integer} = (1920,1080),
                   filename::Union{String,Nothing} = nothing,
                   color::Symbol = :hawaii,
                   labelplatecolor::Union{Symbol,Nothing} = :white,
                   pl::Plots.Plot = heatmap(
                                            aspect_ratio=:equal,
                                            axis=false,
                                            legend=false,
                                            ticks=[],
                                            bg=:black,
                                           )
                  )
    g = Polynomial{Complex{Float64}}(f)+c
    x = range(-aleph*R,aleph*R,length=res)
    y = range(-aleph*R/size[1]*size[2],aleph*R/size[1]*size[2],
              length=round(Int,res/size[1]*size[2]))
    values = juliaValue.(g,complex.(x',y),R,I)
    heatmap!(pl,
             x,y,values,
             color=color,
             padding=0mm,margins=0mm,
             size=size,
             axis=false,
             legend=false,
             bg=:black,
            )
    io = IOBuffer()
    print(io,"\$")
    printpoly(io,g,MIME"text/latex"(),descending_powers=true)
    print(io,"\$")
    annotation = LaTeXString(String(take!(io)))
    annotation_size = Plots.text_size(annotation,14)
    annotcoords=(0.9-0.011*annotation_size[1]/annotation_size[2],1.0,-0.95,-0.85) # x1, x2, y1, y2
    if !isnothing(labelplatecolor)
        plot!(pl,
              Shape(
                    [annotcoords[[1,2,2,1]]...]*aleph*R, # x1, x2, x2, x1
                    [annotcoords[[3,3,4,4]]...]*aleph*R/size[1]*size[2] # y1, y1, y2, y2
                   ),
              opacity=0.1,color=labelplatecolor,linecolor=nothing,
              padding=0mm,margins=0mm,
              axis=false,
              bg=:black,
             )
    end
    annotate!(pl,
              0.9*aleph*R,
              -0.9*aleph*R/size[1]*size[2],
              text(annotation,14,:right),
              size=size,
              padding=0mm,margins=0mm,
              axis=false,
             )

    if !isnothing(filename)
        #closeall() # workaround for darkening issue
        savefig(pl,filename)
    end
    return pl
end # function juliaPlot

function mandelbrotPlot(
                        ;
                        res::Integer = 200,
                        R::Float64 = 2.0,
                        aleph::Float64 = 0.8,
                        I::Integer = 100,
                        f::AbstractVector = [0.0,0.0,1.0],
                        size::Tuple{Integer,Integer} = (1920,1080),
                        filename::Union{String,Nothing} = nothing,
                        color::Symbol = :hawaii,
                        pl::Union{Plots.Plot,Nothing} = heatmap(
                                                                aspect_ratio=:equal,
                                                                axis=false,
                                                                legend=false,
                                                                ticks=[],
                                                                bg=:black,
                                                               ),
                       )::Complex{Float64}
    g = Polynomial{Complex{Float64}}(f)
    x = range(-aleph*R,aleph*R,length=res)
    y = range(-aleph*R/size[1]*size[2],aleph*R/size[1]*size[2],
              length=round(Int,res/size[1]*size[2]))
    values = juliaValue.(g.+complex.(x',y),complex(0.0,0.0),R,I)
    (y_i,x_i) = Tuple(rand(findall( (values .> 0.5*I) .& (values.< 0.9*I))))
    c = complex(x[x_i],y[y_i])
    if !isnothing(pl)
        io = IOBuffer()
        print(io,"\$")
        printpoly(io,g,MIME"text/latex"(),descending_powers=true)
        print(io,"\$")
        annotation = LaTeXString(String(take!(io)))
        heatmap!(pl;size)
        heatmap!(pl,
                 x,y,values,
                 color=color,padding=0mm,margins=0mm,
                 size=size,
                )
        annotate!(pl,
                  0.9*aleph*R,
                  -0.9*aleph*R/size[1]*size[2],
                  text(annotation,14,:right),
                  size=size,
                 )
        plot!(pl,
              [x[x_i]],[y[y_i]],
              seriestype=:scatter,
              marker = (:circle, size[1]/100, :white, stroke(0.2, 0.2, :black)),
              padding=0mm,margins=0mm,
              size=size,
             )
        if !isnothing(filename)
            closeall() # workaround for darkening issue
            savefig(pl,filename)
        end
    end
    return c
end # mandelbrotPlot

function plotBoth(
                  ;
                  f=[0.0,0.0,1.0],
                  res=2000,
                  sizes=(2000,1000),
                  filename=nothing,
                  color=:hawaii,
                 )
    sizes = eltype(sizes)<:Integer ? (sizes,sizes) : sizes
    res = typeof(res)<:Tuple ? res : (res,res)
    filenames = eltype(filename)<:String ? filename : (nothing,nothing)
    pl1 = heatmap(
                  aspect_ratio=:equal,
                  size=sizes[1],
                  axis=false,
                  legend=false,
                  ticks=[],
                  bg=:black,
                 )
    pl2 = heatmap(
                  aspect_ratio=:equal,
                  size=sizes[2],
                  axis=false,
                  legend=false,
                  ticks=[],
                  bg=:black,
                 )
    c = mandelbrotPlot(
                       ;
                       f=f,
                       res=res[1],
                       size=sizes[1],
                       pl=pl1,
                       filename=filenames[1],
                       color=color,
                      )
    juliaPlot(
              ;
              c=c,
              f=f,
              res=res[2],
              size=sizes[2],
              pl=pl2,
              filename=filenames[2],
              color=color,
             )
    l = @layout([
                 a;
                 b
                ])
    pl = plot(pl1,pl2,
              layout=( # TODO I think you have to specify size here...
                      l
                     ),
              size=(maximum(getindex.(sizes,1)),sum(getindex.(sizes,2))))
    if eltype(filename)<:String
        savefig(pl,filename)
    end
    return pl
end # plotBoth

function moreLikelyToBeInterestingPlot(
                                       ;
                                       f=[0.0,0.0,1.0],
                                       res=(300,2000),
                                       sizes=((300,200),(2000,1000)),
                                       filename=nothing,
                                       color=:hawaii,
                                       labelplatecolor=:white,
                                      )
    sizes = eltype(sizes)<:Integer ? (sizes,sizes) : sizes
    res = typeof(res)<:Tuple ? res : (res,res)
    c = mandelbrotPlot(
                       res=res[1],
                       f=f,
                       size=sizes[1],
                       color=color,
                       pl=nothing,
                      )
    juliaPlot(
              c=c, # function offset
              res=res[2], # x resolution
              f=f, # function to iterate
              size=sizes[2],
              filename=filename,
              color=color,
              labelplatecolor=labelplatecolor,
             )
end

function juliaValue(
                    f::Polynomial, # Function to evaluate
                    z_0::Complex, # Starting point
                    R::Real, # Escape radius
                    I::Integer=100, # Max i
                   )::Int64
    i = 0
    z = z_0
    R = R^2
    while( abs2(z) < R && i<I )
        z = f(z)
        i+=1
    end
    return i
end # function juliaValue

function juliaValues(
                     f::Union{Function,Polynomial}, # Function to evaluate
                     z_0::Complex, # Starting point
                     R::Real, # Escape radius
                     I::Integer=100, # Max i
                    )::Vector{Complex{Float64}}
    R = R^2
    return collect(Complex{Float64},takewhile(x->abs2(x)<R,IterTools.take(iterated(f,z_0),I)))
end # function juliaValues

function julianimation(
                       ;
                       f=[0.0,0.0,1.0],
                       res=500,
                       N_t=10,
                       filename=nothing,
                       color=:rainbow,
                       R::Float64 = 2.0, # Escape radius
                       aleph::Float64 = 0.8, # Proportion of escape radius to draw
                       I::Integer = 100, # maximum iteration number
                       size::Tuple{Integer,Integer} = (1920,1080),
                      )

    x = range(-aleph*R,aleph*R,length=res)
    y = range(-aleph*R/size[1]*size[2],aleph*R/size[1]*size[2],length=round(Int,res/size[1]*size[2]))
    mandelbrotvalues=juliaValue.(Polynomial{Complex{Float64}}(f).+complex.(x',y),complex(0.0,0.0),R,I)

    # Choose one coordinate inside and one outside the set
    extr = extrema(mandelbrotvalues)
    lims = [0.9 0.1;0.1 0.9]*[extr...]
    i_small = Tuple(rand(findall( (mandelbrotvalues .< lims[1]) )))
    c_small = Complex(x[i_small[2]],y[i_small[1]])
    i_large = Tuple(rand(findall( (mandelbrotvalues .> lims[2]) )))
    c_large = Complex(x[i_large[2]],y[i_large[1]])
    print("$c_small\t$c_large\t$extr\n")

    @animate for c in range(c_small,c_large,length=N_t)
        print("$c\n")
        juliavalues = juliaValue.(Polynomial{Complex{Float64}}(f)+c,complex.(x',y),R,I)
        pl= heatmap(x,y,juliavalues,ticks=[],colorbar=false)
        heatmap!(pl,x,y,mandelbrotvalues,inset=(1,bbox(0.05,0.05,0.5,0.5*size[2]/size[1],:bottom,:right)),ticks=[],colorbar=false,subplot=2)
        plot!(pl,real.([c_small,c_large]),imag.([c_small,c_large]),subplot=2)
        scatter!(pl,[real(c)],[imag(c)],subplot=2)
    end
end

function mandelbrotMatrix(;
                          res::Integer = 200,
                          R::Float64 = 2.0,
                          aleph::Float64 = 0.8,
                          I::Integer = 100,
                          f::AbstractVector = [0.0,0.0,1.0],
                          size::Tuple{Integer,Integer} = (1920,1080),
                         )
    g = Polynomial{Complex{Float64}}(f)
    x = range(-aleph*R,aleph*R,length=res)
    y = range(-aleph*R/size[1]*size[2],aleph*R/size[1]*size[2],
              length=round(Int,res/size[1]*size[2]))
    values = juliaValue.(g.+complex.(x',y),complex(0.0,0.0),R,I)
end # mandelbrotMatrix

function juliaMatrix(;
                     c::Complex = complex(0.6,0.7), # function offset
                     res::Integer = 200, # x resolution
                     R::Float64 = 2.0, # Escape radius
                     aleph::Float64 = 0.8, # Proportion of escape radius to draw
                     I::Integer = 100, # maximum iteration number
                     f::AbstractVector = [0.0,0.0,1.0], # function to iterate
                     size::Tuple{Integer,Integer} = (1920,1080),
                    )
    g = Polynomial{Complex{Float64}}(f)+c
    x = range(-aleph*R,aleph*R,length=res)
    y = range(-aleph*R/size[1]*size[2],aleph*R/size[1]*size[2],
              length=round(Int,res/size[1]*size[2]))
    values = juliaValue.(g,complex.(x',y),R,I)
end # juliaMatrix

end # module
