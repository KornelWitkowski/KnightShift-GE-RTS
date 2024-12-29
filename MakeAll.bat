for /R %%a in (*.ec) do call _compiler\EarthCP2.bat %%a %%ao

mkdir Scripts
mkdir Scripts\aiplayers
mkdir Scripts\gametypes
mkdir Scripts\gametypes\single
mkdir Scripts\units
mkdir Scripts\units\ai

move aiplayers\*.eco Scripts\aiplayers
copy gametypes\*.eco Scripts\gametypes
move gametypes\*.eco Scripts\gametypes\single
move units\*.eco Scripts\units
move units\ai\*.eco Scripts\units\ai

pause