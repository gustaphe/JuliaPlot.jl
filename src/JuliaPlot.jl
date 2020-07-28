module JuliaPlot
using Plots, Latexify, LaTeXStrings, Printf, Polynomials

export juliaPlot,mandelbrotPlot,plotBoth

function juliaPlot(
                   ;
                   c::Complex = complex(0.6,0.7), # function offset
                   res::Integer = 200, # x resolution
                   R::Float64 = 2.0, # Escape radius
                   aleph::Float64 = 0.8, # Proportion of escape radius to draw
                   I::Integer = 100, # maximum iteration number
                   f::Union{AbstractVector} = [0.0,0.0,1.0], # function to iterate
                   size::Tuple{Integer,Integer} = (1920,1080),
                   filename::Union{String,Nothing} = nothing,
                   colorscheme::Symbol = :hawaii,
                   pl::Plots.Plot = heatmap(
                                            aspect_ratio=:equal,
                                            axis=false,
                                            legend=nothing,
                                            ticks=nothing,
                                            bg=:black,
                                           )
                  )
    heatmap!(pl,size=size);
    g = Polynomial(f)+c
    x = range(-aleph*R,aleph*R,length=res);
    y = range(-aleph*R/size[1]*size[2],aleph*R/size[1]*size[2],length=round(Int,res/size[1]*size[2]));
    values = juliaValue.(g,complex.(x',y),R,I)
    heatmap!(pl,
             x,y,values,
             color=colorscheme,padding=(0.0,0.0),margins=(0.0,0.0),
            );
    io = IOBuffer();
    print(io,"\$");
    printpoly(io,g,MIME"text/latex"(),descending_powers=true);
    print(io,"\$");
    annotation = LaTeXString(String(take!(io)));
    annotate!(pl,
              0.95*aleph*R,
              -0.9*aleph*R/size[1]*size[2],
              text(annotation,14,:right),
             );
    if !isnothing(filename)
        savefig(pl,filename)
    end
    return pl;
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
                        colorscheme::Symbol = :hawaii,
                        pl::Plots.Plot = heatmap(
                                                 aspect_ratio=:equal,
                                                 axis=false,
                                                 legend=nothing,
                                                 ticks=nothing,
                                                 bg=:black,
                                                ),
                       )::Complex{Float64}
    heatmap!(pl,size=size);
    g = Polynomial(f);
    x = range(-aleph*R,aleph*R,length=res);
    y = range(-aleph*R/size[1]*size[2],aleph*R/size[1]*size[2],length=round(Int,res/size[1]*size[2]));
    values = juliaValue.(g.+complex.(x',y),complex(0.0,0.0),R,I);
    heatmap!(pl,
             x,y,values,
             color=colorscheme,padding=(0.0,0.0),margins=(0.0,0.0),
            );
    (y_i,x_i) = Tuple(rand(findall( (values .> 0.5*I) .& (values.< 0.9*I))));
    c = complex(x[x_i],y[y_i]);
    plot!(pl,
          [x[x_i]],[y[y_i]],
          seriestype=:scatter,
          color=:black
         )
    return c;
end

function plotBoth(
                  ;
                  f=[0.0,0.0,1.0],
                  res=2000,
                  size=(2000,1000),
                 )
    pl1 = heatmap(
                  aspect_ratio=:equal,
                  size=size,
                  axis=false,
                  legend=nothing,
                  ticks=nothing,
                  bg=:black,
                 )
    pl2 = heatmap(
                  aspect_ratio=:equal,
                  size=size,
                  axis=false,
                  legend=nothing,
                  ticks=nothing,
                  bg=:black,
                 )
    c = mandelbrotPlot(
                       ;
                       f=f,
                       res=res,
                       size=size,
                       pl=pl1,
                      )
    juliaPlot(
              ;
              c=c,
              f=f,
              res=res,
              size=size,
              pl=pl2,
             )
    return plot(pl1,pl2,layout=(2,1))
end

function juliaValue(
                    f::Polynomial, # Function to evaluate
                    z_0::Complex, # Starting point
                    R::Real, # Escape radius
                    I::Integer=100, # Max i
                   )::Int64
    i = 0;
    z=z_0;
    R = R^2;
    while( abs2(z) < R && i<I )
        z = f(z);
        i+=1;
    end
    return i;
end # function juliaValue

function juliaValues(
                     f::Union{Function,Polynomial}, # Function to evaluate
                     z_0::Complex, # Starting point
                     R::Real, # Escape radius
                     I::Integer=100, # Max i
                    )::Vector{Complex{Float64}}
    R = R^2;
    return collect(Complex{Float64},takewhile(x->abs2(x)<R,IterTools.take(iterated(f,z_0),I)));
end # function juliaValue

end # module
