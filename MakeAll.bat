REM Compile general scripts
for /R %%a in (*.ec) do call _compiler\EarthCP2.bat %%a %%ao

REM Compile unit scripts with their specific GUIDs
call _compiler\EarthCP2.bat Units\Animal.ec Units\Animal.eco -g EAEAEAEA-0900-0900-0000-000000000001
call _compiler\EarthCP2.bat Units\BuilderScript.ec Units\BuilderScript.eco -g EAEAEAEA-0900-0900-0000-000000000003
call _compiler\EarthCP2.bat Units\Capturer.ec Units\Capturer.eco -g EAEAEAEA-0900-0900-0000-000000000002
call _compiler\EarthCP2.bat Units\HarvesterScript.ec Units\HarvesterScript.eco -g EAEAEAEA-0900-0900-0000-000000000004
call _compiler\EarthCP2.bat Units\RPGUnitScript.ec Units\RPGUnitScript.eco -g EAEAEAEA-0900-0900-0000-000000000006
call _compiler\EarthCP2.bat Units\Unit.ec Units\Unit.eco -g EAEAEAEA-0900-0900-0000-000000000000

REM Create directories
mkdir Scripts
mkdir Scripts\aiplayers
mkdir Scripts\gametypes
mkdir Scripts\gametypes\single
mkdir Scripts\units
mkdir Scripts\units\ai

REM Move compiled files
move aiplayers\*.eco Scripts\aiplayers
copy gametypes\*.eco Scripts\gametypes
move gametypes\*.eco Scripts\gametypes\single
move units\*.eco Scripts\units
move units\ai\*.eco Scripts\units\ai

pause