rem ### Tonton ###
rem # (19/02/2023)

rem *********************DEBUT************************
@echo off
cls

setlocal enableextensions
setlocal enabledelayedexpansion
set "MIST=%CD%"
set "D64=%MIST%\D64"
set "LOGFILE=%MIST%\script.log"
set "LOGERROR=%MIST%\script_errors.log"
set /a nbnfo=50

echo "Opération de tri par !nbnfo! fichiers nfo en cours"
echo ..........

call :log "script.log" "Script log"
call :log "script_errors.log" "Script Error"
call :main >>"%LOGFILE%" 2>>"%LOGERROR%"
rem exit
rem **********************FIN************************
goto :EOF

rem -----------------Sous Routine LOG----------------
:log
setlocal
set "FILE=%MIST%\%~1"
echo %~2 > "%FILE%"
echo. >> "%FILE%" & echo ================= >> "%FILE%"
echo Date: %date% %time% >> "%FILE%" & echo ================= >> "%FILE%"
echo. >> "%FILE%"
exit /b
endlocal
rem -----------------Fin Sous Routine LOG----------------
goto :EOF

rem -----------------Sous Routine GTR----------------
:gtr
setlocal EnableDelayedExpansion
for /d %%D in (*) do (
    REM Cas sous-dossier Numérique
    for /f "delims=" %%D in ('dir /b /ad ^| findstr /r "^[1-9]$"') do (
        set "dirnumber=%%~nD"
        set "newname=0!dirnumber!"
        ren "%%~fD" "!newname!"

	)
    REM Cas sous dossier Alpha-Numérique
    for /f "delims=" %%D in ('dir /b /ad ^| findstr /r "^[A-Za-z][1-9]$"') do (
        set "dirname=%%D"
        set "letter=!dirname:~0,1!"
        set "number=!dirname:~1!"
        set "newname=!letter!0!number!"
        echo Renaming %%D to !newname!
        ren "%%D" "!newname!"
        )
    )
endlocal
exit /b
rem -----------------Fin Sous Routine GTR----------------
goto :EOF

rem -----------------Sous Routine MAIN----------------
:main
setlocal enabledelayedexpansion
pushd "%D64%"
    for /d %%d in ("*") do (
        set "folder=%%d"

        for /F %%c in ('dir !folder!\*.nfo /A-D /B ^| find "." /C') do set count=%%c

        pushd "%D64%\!folder!"
            if !count! gtr !nbnfo! (
                set /a foldercount=1
                set /a filecount=1
                set "subfoldername=!folder!!foldercount!"
                mkdir !subfoldername!

                for %%f in (*.nfo) do (
                    set filename=%%~nf

                    if !filecount! gtr !nbnfo! (
                        set /a "foldercount+=1"
                        set /a filecount=1
                        set "subfoldername=!folder!!foldercount!"
                        mkdir !subfoldername!
                    )

                    set /a "filecount+=1"
                    move "!filename!"*.*  "!subfoldername!"
                )
                call :gtr
            )
        popd
    )
popd
endlocal
exit /b
rem -----------------Fin Sous Routine MAIN----------------
goto :EOF

:FIN
