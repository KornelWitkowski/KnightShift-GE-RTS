REM Compile general scripts
for /R rpg %%a in (*.ec) do call _compiler\EarthCP2.bat %%a %%ao
for /R aiplayers %%a in (*.ec) do call _compiler\EarthCP2.bat %%a %%ao
for /R gametypes %%a in (*.ec) do call _compiler\EarthCP2.bat %%a %%ao
for /R campaigns/Campaigns1/Missions %%a in (*.ec) do call _compiler\EarthCP2.bat %%a %%ao

REM Compile unit scripts with their specific GUIDs
call _compiler\EarthCP2.bat Units\Animal.ec Units\Animal.eco -g EAEAEAEA-0900-0900-0000-000000000001
call _compiler\EarthCP2.bat Units\BuilderScript.ec Units\BuilderScript.eco -g EAEAEAEA-0900-0900-0000-000000000003
call _compiler\EarthCP2.bat Units\Capturer.ec Units\Capturer.eco -g EAEAEAEA-0900-0900-0000-000000000002
call _compiler\EarthCP2.bat Units\HarvesterScript.ec Units\HarvesterScript.eco -g EAEAEAEA-0900-0900-0000-000000000004
call _compiler\EarthCP2.bat Units\RPGUnitScript.ec Units\RPGUnitScript.eco -g EAEAEAEA-0900-0900-0000-000000000006
call _compiler\EarthCP2.bat Units\Unit.ec Units\Unit.eco -g EAEAEAEA-0900-0900-0000-000000000000

call _compiler\EarthCP2.bat Units\Ai\AnimalAI.ec Units\Ai\AnimalAI.eco -g EAEAEAEA-0900-0900-0000-000000000101
call _compiler\EarthCP2.bat Units\Ai\BuilderScriptAI.ec Units\Ai\BuilderScriptAI.eco -g EAEAEAEA-0900-0900-0000-000000000103
call _compiler\EarthCP2.bat Units\Ai\CapturerAI.ec Units\Ai\CapturerAI.eco -g EAEAEAEA-0900-0900-0000-000000000102
call _compiler\EarthCP2.bat Units\Ai\HarvesterScriptAI.ec Units\Ai\HarvesterScriptAI.eco -g EAEAEAEA-0900-0900-0000-000000000104
call _compiler\EarthCP2.bat Units\Ai\PlatoonAI.ec Units\Ai\PlatoonAI.eco -g EAEAEAEA-0900-0900-0000-000000000105
call _compiler\EarthCP2.bat Units\Ai\RPGUnitScriptAI.ec Units\Ai\RPGUnitScriptAI.eco -g EAEAEAEA-0900-0900-0000-000000000106
call _compiler\EarthCP2.bat Units\Ai\UnitAI.ec Units\Ai\UnitAI.eco -g EAEAEAEA-0900-0900-0000-000000000100

REM Create directories
if not exist Scripts mkdir Scripts
if not exist Scripts\aiplayers mkdir Scripts\aiplayers
if not exist Scripts\gametypes mkdir Scripts\gametypes
if not exist Scripts\gametypes\single mkdir Scripts\gametypes\single
if not exist Scripts\units mkdir Scripts\units
if not exist Scripts\units\ai mkdir Scripts\units\ai
if not exist Scripts\campaigns\Campaigns1\Missions mkdir Scripts\campaigns\Campaigns1\Missions

REM Move compiled files
move aiplayers\*.eco Scripts\aiplayers
copy gametypes\*.eco Scripts\gametypes
copy rpg\*.eco Scripts\gametypes
move gametypes\*.eco Scripts\gametypes\single
move rpg\*.eco Scripts\gametypes\single
move units\*.eco Scripts\units
move units\ai\*.eco Scripts\units\ai
move campaigns\Campaigns1\Missions\*.eco Scripts\campaigns\Campaigns1\Missions

pause