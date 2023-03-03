rem ### Tonton ###
rem # (03/12/2022)

rem 21/02/2023
rem Reprise Script

rem *********************DEBUT************************
@echo off

SETLOCAL enabledelayedexpansion
set /A Compt=0
set /A Compt2=0
set /A Compt3=1
set "LOGFILE=%MIST%\%0.log"
set "LOGERROR=%MIST%\%0_errors.log"

call :log %LOGFILE% "%0 Log"
call :log %LOGERROR% "%0 Log Error"

for /f "delims=" %%a In ('dir /ad/b/s  "." ') Do (
    cd "%%a"
    dir *.d64;*.g64;*.t64 /A /B /O:GEN > filelist.txt
    del *.lst 2>nul

    for /f "delims=" %%l in (filelist.txt) do call:lst "%%l" >>"%LOGFILE%" 2>>"%LOGERROR%"
	del filelist.txt
    cd ..
)

rem exit
rem **********************FIN************************
goto :FIN

rem -----------------Sous Routine LOG----------------
:log
set "FILE=%~1"
echo %~2 > "%FILE%"
echo. >> "%FILE%" & echo ================= >> "%FILE%"
echo Date: %date% %time% >> "%FILE%" & echo ================= >> "%FILE%"
echo. >> "%FILE%"
rem -----------------Fin Sous Routine LOG----------------
goto :FIN

rem -----------------Sous Routine LST----------------
:lst
set nom="%1"
set nom2=!nom:~2,-2!

for /F "tokens=1,2 delims=_" %%i in ("%nom%") do set nom3=%%i.lst

echo "%nom%" | find "_" 2>nul
if not "%errorlevel%"=="0" (for /F "tokens=1,2 delims=-" %%i in ("%nom%") do set nom3=%%i.lst)

for /f "tokens=1,* delims=[,]" %%C in ('"%comspec% /u /c echo %nom2%|more|find /n /v """') do set /a Compt=%%C-4

set /A ComptP=%Compt%+1
set /A ComptM=%Compt%-1

for /L %%x in (0,1,2) do (
    if  %%x=="2" do (
        set /A Compt=%Compt%-%%x
    )
    set /A Compt=%Compt+%%x
    if %Compt%==%Compt2% (
        if "%nom3%"=="%nom3old%" (
            set /A Compt3+=1
            if %Compt3% gtr 1 (
                echo "%nom2%" >> "%nom3%"
                goto :else
            )
            echo "%nomold%" >> "%nom3%"
            echo "%nom2%" >> "%nom3%"
        )
    )
)
rem -----------------Fin Sous Routine LST----------------
goto :FIN

rem -----------------Sous Routine ELSE----------------
:else
if "%nom3%" NEQ "%nom3old%" (set /A Compt3=1)

set nomold=%nom2%
set nom3old=%nom3%
set Compt2=%Compt%
rem -----------------Fin Sous Routine ELSE----------------
goto :FIN

:FIN
