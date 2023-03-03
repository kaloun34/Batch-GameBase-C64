rem ### Tonton ###
rem # (19/02/2023)

rem *********************DEBUT************************
@echo off
setlocal enableextensions
setlocal enabledelayedexpansion
set "MIST=%CD:~0,-1%"
set "D64=%MIST%\D64"
set "LOGFILE=%MIST%\script.log"
set "LOGERROR=%MIST%\script_errors.log"

call :log "script.log" "Script log"
call :log "script_errors.log" "Script Error"
call :main >>"%LOGFILE%" 2>>"%LOGERROR%"
rem exit
rem **********************FIN************************
goto :FIN

rem -----------------Sous Routine LOG----------------
:log
set "FILE=%MIST%\%~1"
echo %~2 > "%FILE%"
echo. >> "%FILE%" & echo ================= >> "%FILE%"
echo Date: %date% %time% >> "%FILE%" & echo ================= >> "%FILE%"
echo. >> "%FILE%"
rem -----------------Fin Sous Routine LOG----------------
goto :FIN

rem -----------------Sous Routine MAIN----------------
:main
pushd "%D64%"
    for /d %%d in ("*") do (
        set "folder=%%d"

        for /F %%c in ('dir !folder!\*.nfo /A-D /B ^| find "." /C') do set count=%%c

        pushd "%D64%\!folder!"
            if !count! gtr 500 (
                set /a foldercount=1
                set /a filecount=1
                set "subfoldername=!folder!!foldercount!"
                mkdir !subfoldername!

                for %%f in (*.nfo) do (
                    set filename=%%~nf

                    if !filecount! gtr 500 (
                        set /a "foldercount+=1"
                        set /a filecount=1
                        set "subfoldername=!folder!!foldercount!"
                        mkdir !subfoldername!
                    )

                    set /a "filecount+=1"
                    move "!filename!"*.*  "!subfoldername!"
                 )
        )
        popd
    )
popd
rem rem -----------------Fin Sous Routine MAIN----------------
goto :FIN

:FIN
