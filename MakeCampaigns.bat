REM Compile general scripts
for /R campaigns/Campaigns1/Missions %%a in (*.ec) do call _compiler\EarthCP2.bat %%a %%ao

REM Create directories
if not exist Scripts mkdir Scripts
if not exist Scripts\campaigns mkdir Scripts\campaigns
if not exist Scripts\campaigns\Campaigns1 mkdir Scripts\campaigns\Campaigns1
if not exist Scripts\campaigns\Campaigns1\Missions mkdir Scripts\campaigns\Campaigns1\Missions

REM Move compiled files
move campaigns\Campaigns1\Missions\*.eco Scripts\campaigns\Campaigns1\Missions

pause