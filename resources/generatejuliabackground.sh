#! /bin/zsh
notify-send "Generating new Julia background"
/usr/local/bin/generatejuliabackground.jl
feh --bg-fill --no-xinerama ~/Images/Julia/background.png
notify-send "Background generated" -i ~/Images/Julia/background.png
