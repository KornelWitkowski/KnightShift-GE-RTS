REM Compile general scripts
for /R aiplayers %%a in (*.ec) do call _compiler\EarthCP2.bat %%a %%ao

REM Create directories
if not exist Scripts mkdir Scripts
if not exist Scripts\aiplayers mkdir Scripts\aiplayers

REM Move compiled files
move aiplayers\*.eco Scripts\aiplayers

pause