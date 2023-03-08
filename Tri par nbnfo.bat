rem ### Tonton ###
rem # (19/02/2023)

:: *********************DEBUT************************
@echo off
cls

rem CHCP 1252
setlocal enableextensions
setlocal enabledelayedexpansion
set "MIST=%CD%"
set "D64=%MIST%\D64"
set "script=%~n0"
set "LOGFILE=%MIST%\%script%.log"
set "LOGERROR=%MIST%\%script%_errors.log"
set /a nbnfo=50

echo "Op�ration de tri par !nbnfo! fichiers nfo en cours"
echo ..........

call :log "%LOGFILE%" "%script% Log"
call :log "%LOGERROR%" "%script% Log Error"
call :main >>"%LOGFILE%" 2>>"%LOGERROR%"
rem exit
:: **********************FIN************************
goto :EOF



:: -----------------Sous Routine LOG----------------
:log
	setlocal
	set "FILE=%~1"
	echo %~2 > "%FILE%"
	echo. >> "%FILE%" & echo ================= >> "%FILE%"
	echo Date: %date% %time% >> "%FILE%" & echo ================= >> "%FILE%"
	echo. >> "%FILE%"
	endlocal
exit /b
:: -----------------Fin Sous Routine LOG----------------


:: -----------------Sous Routine GTR----------------
:gtr
	setlocal EnableDelayedExpansion
	for /d %%D in (*) do (
		rem: Dossiers compos�s d'une lettre et d'un chiffre
        for /f "delims=" %%D in ('dir /b /ad /on ^| findstr /r "^[A-Za-z][1-9]$"') do (
            set "dirname=%%D"
            set "letter=!dirname:~0,1!"
            set "number=!dirname:~1!"
            set "newname=!letter! [0!number!]"
            ren "%%D" "!newname!"
        )

		rem: les autres dossiers
        for /f "delims=" %%F in ('dir /b /on ^| findstr /v /r "^[A-Za-z][1-9]$"') do (
            set "dirname=%%D"
            set "letter=!dirname:~0,1!"
            set "number=!dirname:~1!"
            if "!letter!"=="0" (
				rem: le cas du dossier 0
                set "newname=!letter! [0!number!]"
            ) else (
                rem: une lettre et d�j� deux chiffres
                set "newname=!letter! [!number!]"
            )
            ren "%%D" "!newname!"
        )
	)
	endlocal
exit /b
:: -----------------Fin Sous Routine GTR----------------


:: -----------------Routine MAIN----------------
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
:: -----------------Fin Routine MAIN----------------


:EOF
