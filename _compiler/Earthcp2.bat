echo off
set DEL_PARAM=
if "%OS%" == "Windows_NT" set DEL_PARAM=/F
Echo Compiling...
_compiler\cl.exe /nologo /E %CL_PARAM% %1 > %1-preprocessed
if not errorlevel 1 _compiler\EarthCP2.exe -w- -nologo -noresult %3 %4 %1-preprocessed %2
del %DEL_PARAM% %1-preprocessed
