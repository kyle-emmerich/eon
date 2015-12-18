# eon
![Screenshot](http://puu.sh/lZW6o/ccebd8a7ed.png)

Tribute to StarSonata and AstroBattle, two of my favorite old 2D space games

If you're on Windows and want to use run.bat, just change the variables at the top of the script. They're very self-explanatory. If you're not on Windows, all the script does is launch both a server and client instance. You can recreate this by writing a script that runs the following two commands:

    love [FOLDER] server
    love [FOLDER] client
    
Replace [FOLDER] with the path to where main.lua resides, without including main.lua itself. In other words, the game directory.

Requires LOVE 0.10.0. You can download 0.10.0 binaries [here](https://love2d.org/builds/).