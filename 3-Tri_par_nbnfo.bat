rem ### Tonton ###
rem # (19/02/2023)

:: *********************DEBUT************************
@echo off
cls

CHCP 1252
setlocal enableextensions
setlocal enabledelayedexpansion
set "MIST=%CD%"
set "D64=%MIST%\D64"
set "script=%~n0"
set "LOGFILE=%MIST%\%script%.log"
set "LOGERROR=%MIST%\%script%_errors.log"
set /a nbnfo=50

echo "Opération de tri par !nbnfo! fichiers nfo en cours"
echo ..........

call :log "%LOGFILE%" "%script% Log"
call :log "%LOGERROR%" "%script% Log Error"
call :main >>"%LOGFILE%" 2>>"%LOGERROR%"
rem exit
:: **********************FIN************************
goto :EOF



:: -----------------Routine LOG----------------
:log
	setlocal
	set "FILE=%~1"
	echo %~2 > "%FILE%"
	echo. >> "%FILE%" & echo ================= >> "%FILE%"
	echo Date: %date% %time% >> "%FILE%" & echo ================= >> "%FILE%"
	echo. >> "%FILE%"
	endlocal
exit /b
:: -----------------Fin Routine LOG----------------


:: -----------------Routine GTR----------------
:gtr
	setlocal EnableDelayedExpansion
	for /d %%D in (*) do (
		rem: Dossiers composés d'une lettre et un chiffre
		for /f "delims=" %%D in ('dir /b /ad /on ^| findstr /r "^[A-Za-z][0-9]$"') do (
			set "dirname=%%D"
			set "letter=!dirname:~0,1!"
			set "number=!dirname:~1!"
			set "newname=!letter! [0!number!]"
			ren "%%D" "!newname!"
		)

		rem: Dossiers composés d'une lettre et plusieurs chiffres
		for /f "delims=" %%D in ('dir /b /ad /on ^| findstr /r "^[A-Za-z][1-9][0-9]*$"') do (
			set "dirname=%%D"
			set "letter=!dirname:~0,1!"
			set "number=!dirname:~1!"
			set "newname=!letter! [!number!]"
			ren "%%D" "!newname!"
		)

		rem: Dossiers composés uniquement de chiffres
		for /f "delims=" %%D in ('dir /b /ad /on ^| findstr /r "^[0-9][0-9]*$"') do (
			set "dirname=%%D"
			set "letter=0"
			set /a "num=!dirname!"
			set "newname=!letter! [!dirname!]"
			ren "%%D" "!newname!"
		)
	)
	endlocal
exit /b
:: -----------------Fin Routine GTR----------------


:: -----------------Routine FLST----------------
:flst
    setlocal EnableDelayedExpansion
    rem: pour tous dossiers first + last file
    for /d %%D in (*) do (
        pushd "%%D"
            for /f "delims=" %%F in ('dir /b /a-d /o-n *.nfo') do (
                set "First=%%~nF"
                set "First=!First:~0,4!"
            )

            for /f "delims=" %%L in ('dir /b /a-d /on *.nfo') do (
                set "Last=%%~nL"
                set "Last=!Last:~0,4!"
            )
        popd

		set "debF=!First:~0,1!"
		set "restF=!First:~1!"
		set "debL=!Last:~0,1!"
		set "restL=!Last:~1!"

        call :Majmin restF
		set "Firstr=!debF!!restF!"

		call :Majmin restL
		set "Lastr=!debL!!restL!"

		echo "Firstr: !Firstr!"
		echo "Lastr: !LAstr!"

        ren "%%D" "%%D  (!Firstr! -- !Lastr!)"

    )
    endlocal
exit /b
:: -----------------Fin Routine FLST----------------


:: -----------------Routine Majmin----------------
:Majmin
	for %%z in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do call set "%~1=%%%~1:%%z=%%z%%"
	echo "min: %~1"
exit /b
:: -----------------fin Routine Majmin----------------


:: -----------------Routine MAIN----------------
:main
	setlocal enabledelayedexpansion
	pushd "%D64%"
		for /d %%d in ("*") do (
			set "folder=%%d"

			for /F %%c in ('dir !folder!\*.nfo /A-D /B ^| find "." /C') do set count=%%c

			if !count! gtr !nbnfo! (
				pushd "%D64%\!folder!"
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
					call :flst
				popd
			)
		)
	popd
	endlocal
exit /b
:: -----------------Fin Routine MAIN----------------


:EOF
