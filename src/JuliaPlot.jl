module JuliaPlot
using Plots, Latexify, LaTeXStrings, Printf, Polynomials

export juliaPlot

function juliaPlot(
                   ;
                   c::Complex = complex(0.6,0.7), # function offset
                   res::Integer = 200, # x resolution
                   R::Float64 = 5.0, # Escape radius
                   aleph::Float64 = 0.8, # Proportion of escape radius to draw
                   I::Integer = 100, # maximum iteration number
                   f::Union{Function,Polynomial{Complex},AbstractVector} = Polynomial{Complex}([0.0,0.0,1.0]), # function to iterate
                   size::Tuple{Integer,Integer} = (1920,1080),
                   filename::Union{String,Nothing} = nothing,
                  )::Plots.Plot{Plots.GRBackend}
    if isa(f,Function)
        g(z) = f(z)+c;
    elseif isa(f,AbstractVector)
        g = Polynomial(f)+c
    else
        g = f+c
    end
    pl = heatmap(
                 aspect_ratio=:equal,
                 size=size,
                 axis=false,
                 legend=nothing,
                 ticks=nothing,
                 bg=:black,
                )
    x = range(-aleph*R,aleph*R,length=res);
    y = range(-aleph*R/size[1]*size[2],aleph*R/size[1]*size[2],length=round(Int,res/size[1]*size[2]));
    heatmap!(pl,
             x,y,juliaValue.(g,complex.(x',y),R,I),
             color=:hawaii,padding=(0.0,0.0),margins=(0.0,0.0),
            );
    if isa(f,Function)
        annotation = LaTeXString(@sprintf("\$c=%.4f%+.4fi\$",real(c),imag(c)))
    else
        io = IOBuffer();
        print(io,"\$");
        printpoly(io,g,MIME"text/latex"(),descending_powers=true);
        print(io,"\$");
        annotation = LaTeXString(String(take!(io)));
    end
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

function juliaValue(
                    f::Union{Function,Polynomial}, # Function to evaluate
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
end # function juliaValue2

end # module
