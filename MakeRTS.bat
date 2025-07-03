REM Compile general scripts
for /R gametypes %%a in (*.ec) do call _compiler\EarthCP2.bat %%a %%ao

REM Create directories
if not exist Scripts mkdir Scripts
if not exist Scripts\gametypes mkdir Scripts\gametypes
if not exist Scripts\gametypes\single mkdir Scripts\gametypes\single

REM Move compiled files
copy gametypes\*.eco Scripts\gametypes
move gametypes\*.eco Scripts\gametypes\single

pause