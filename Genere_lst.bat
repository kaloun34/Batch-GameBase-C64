rem ### Tonton ###
rem # (03/12/2022)

rem 21/02/2023
rem Reprise Script

rem *********************DEBUT************************
@echo off

rem CHCP 1252
setlocal enableextensions
setlocal enabledelayedexpansion

set "MIST=%CD%"
set "D64=%MIST%\D64"
set "script=%~n0"
set "LOGFILE=%MIST%\%script%.log"
set "LOGERROR=%MIST%\%script%_errors.log"
set /A Compt=0
set /A Compt2=0
set /A Compt3=1

call :log %LOGFILE% "%script% Log"
call :log %LOGERROR% "%script% Log Error"

pushd "%D64%"
    for /f "delims=" %%a In ('dir /ad/b/s  "." ') Do (
        cd "%%a"
        dir *.d64;*.g64;*.t64 /A /B /O:GEN > filelist.txt
        del *.lst 2>nul

        for /f "delims=" %%l in (filelist.txt) do call:lst "%%l" >>"%LOGFILE%" 2>>"%LOGERROR%"
	
        del filelist.txt
        cd ..
    )
popd
goto:EOF
rem exit
rem **********************FIN************************



rem -----------------Sous Routine LOG----------------
:log
	setlocal 
	set "FILE=%~1"
	echo %~2 > "%FILE%"
	echo. >> "%FILE%" & echo ================= >> "%FILE%"
	echo Date: %date% %time% >> "%FILE%" & echo ================= >> "%FILE%"
	echo. >> "%FILE%"
	endlocal
exit /b
rem -----------------Fin Sous Routine LOG----------------


rem -----------------Sous Routine LST----------------
:lst
rem setlocal enabledelayedexpansion
    set nom="%1"
    set nom2=!nom:~2,-2!
    
    for /F "tokens=1,2 delims=_" %%i in ("%nom%") do set nom3=%%i.lst
    
    echo "%nom%" | find "_" 2>nul
    
    if not "%errorlevel%"=="0" (
        for /F "tokens=1,2 delims=-" %%i in ("%nom%") do set nom3=%%i.lst
    )

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
                    echo !nom2! >> "%nom3%"
                    goto else
                )
                echo !nomold! >> "%nom3%"
                echo !nom2! >> "%nom3%"   
            )
        )
    )

    :else
        if "%nom3%" NEQ "%nom3old%" (set /A Compt3=1)

            set nomold=%nom2%
            set nom3old=%nom3%
            set Compt2=%Compt%
rem endlocal
exit /b

:EOF
