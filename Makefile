dev/JuliaPlotSysImage.so : src/JuliaPlot.jl
	julia --project=dev -e "using JuliaPlot, PackageCompiler;create_sysimage(;sysimage_path=\"dev/JuliaPlotSysimage.so\")"
