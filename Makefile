dev/JuliaPlotSysImage.so : src/JuliaPlot.jl
	@ echo "Takes about 4 minutes"
	julia +release --project=dev -e "using JuliaPlot, PackageCompiler;create_sysimage(;sysimage_path=\"dev/JuliaPlotSysimage.so\")"
