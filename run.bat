set LOVEPATH="C:\Program Files (x86)\LOVE\love.exe"
set EONDIR="C:\Users\Kyle\Documents\eon"
echo Starting the server...
start "Eon Server" %LOVEPATH% %EONDIR% server
echo Starting the client.
start "Eon Client" %LOVEPATH% %EONDIR% client
pause