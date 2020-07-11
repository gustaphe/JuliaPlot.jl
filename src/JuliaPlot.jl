module JuliaPlot
using Plots, LaTeXStrings, Printf

export juliaPlot()

function juliaPlot(
		   ;
		   c::Complex = complex(0.6,0.7), # function offset
		   res::Integer = 200, # x resolution
		   R::Float64 = 5.0, # Escape radius
		   aleph::Float64 = 0.8, # Proportion of escape radius to show
		   I::Integer = 100, # maximum iteration number
		   )::Plots.Plot{Plots.GRBackend}
	f(z) = z^2+c;
	size = (1920,1080);
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
		 x,y,juliaValue.(f,complex.(x',y),R,I),
		 color=:hawaii,padding=(0.0,0.0),margins=(0.0,0.0),
		 );
	annotate!(pl,
		  0.85*aleph*R,
		  -0.9*aleph*R/size[1]*size[2],
		  LaTeXString(@sprintf("\$c=%.4f%+.4fi\$",real(c),imag(c))),
		  );
	return pl;
end # function juliaPlot

function juliaValue(
		    f::Function, # Function to evaluate
		    z_0::Complex, # Starting point
		    R::Real, # Escape radius
		    I::Integer=100, # Max i
		    )::Int64
	i = 0;
	z=z_0;
	while( abs2(z) < R^2 && i<I )
		z = f(z);
		i+=1;
	end
	return i;
end # function juliaValue

end # module
