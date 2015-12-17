set LOVEPATH="C:\Program Files\LOVE\love.exe"
set EONDIR="Z:\Development\LOVE\eon"
echo Starting the server...
start "Eon Server" %LOVEPATH% %EONDIR% server
echo Starting the client.
start "Eon Client" %LOVEPATH% %EONDIR% client
pause