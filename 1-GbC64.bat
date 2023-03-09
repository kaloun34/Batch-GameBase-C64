rem ### Tonton ###
rem # (09/08/2021)
rem #
rem # 09/02/2023
rem # Reprise du script

rem *********************DEBUT************************
@echo off
cls

setlocal enableextensions
set "script=%~n0"

echo "Script %script% en cours de traitement"
echo ..........

set "MIST=%cd%"
set "GB64=C:\GameBase\Commodore 64"
set "D64=%MIST%\D64"
set "TEMP=%D64%\temp"
set "ZIP=%GB64%\Games"
set "TOOLS=%GB64%\Emulators"
set "LOGFILE=%MIST%\%script%.log"
set "LOGERROR=%MIST%\%script%_errors.log"

call :log %LOGFILE% "%script% Log"
call :log %LOGERROR% "%script% Log Error"

rmdir /Q /S %D64% >nul 2>>"%LOGERROR%"
mkdir %TEMP%

pushd "%ZIP%"
	for /f "delims=" %%d In ('dir /ad/b/s  "." ') do (
		cd "%%d" >nul 2>>"%LOGERROR%"
		for %%z in (*.zip) do (
			7z.exe -y x "%%z" -o"%TEMP%" >nul 2>>"%LOGERROR%"
			pushd %TEMP%
				for %%x in (*.t64) do (
					"%TOOLS%"\c1541.exe -format "fromt64,01" d64 "%%~nx.d64" -tape "%%x" >nul 2>>"%LOGERROR%"
					del "%%x" >nul 2>>"%LOGERROR%"
				)

				for /f "delims=" %%a in ('dir /a:-d /o:n /b *.d64 *.crt *.tap *.g64 *.d81 *.reu *.prg *.t64') do ( call :suppr "%%a" >nul 2>>"%LOGERROR%" )

				call :name >nul 2>>"%LOGERROR%"
			popd

            rem appel des sous-routines SUITE, MINUS et TRI en delayedexpansion
			call :sroutines >nul 2>>"%LOGERROR%"
		)
		cd..
	)
popd

rmdir /S /Q %TEMP%
exit
rem **********************FIN************************



rem -----------------Sous Routine LOG----------------
rem Utilisation : call kkwett >>"%LOGFILE%" 2>>"%LOGERROR%"
				: call kkwett >nul 2>>"%LOGERROR%"
				: call kkwett >>"%LOGFILE%" >nul
:log
set "FILE=%~1"
echo %~2 > "%FILE%"
echo. >> "%FILE%" & echo ================= >> "%FILE%"
echo Date: %date% %time% >> "%FILE%" & echo ================= >> "%FILE%"
echo. >> "%FILE%"
exit /b
rem -----------------Fin Sous Routine LOG----------------


rem -----------------Sous Routine SUPPR----------------
:suppr
    rem Suppression du ! dans le nom de fichier qui est bloquant sur un delayedexpansion
    set "oldname=%~nx1"
    set "newname=%oldname:!=x%"
    if "%newname%" neq "%~nx1" ( ren "%oldname%" "%newname%" )
exit /b
rem -----------------Fin Sous Routine SUPPR----------------


rem -----------------Sous Routine NAME---------------
:name
setlocal enabledelayedexpansion
    CHCP 1252
    rem Extraction des informations du fichier version.nfo de chaque jeux
    for /f "tokens=1,* delims=: " %%a in ('type version.nfo ^| findstr /C:"Name:" /C:"Published:" /C:"Language:" /C:"Players:" /C:"Control:"') do (
		if "%%a"=="Name" (
			set "name=%%b"
			set "name=!name:à=a!"
			set "name=!name:á=a!"
			set "name=!name:ã=a!"
			set "name=!name:ä=a!"
			set "name=!name:ç=c!"
			set "name=!name:è=e!"
			set "name=!name:é=e!"
			set "name=!name:ê=e!"
			set "name=!name:ò=o!"
			set "name=!name:ó=o!"
			set "name=!name:ô=o!"
			set "name=!name:ö=o!"
			set "name=!name:ø=o!"
			set "name=!name:ù=u!"
			set "name=!name:ú=u!"
			set "name=!name:û=u!"
			set "name=!name:ü=u!"
			set "name=!name:ý=y!"
			set "name=!name:ÿ=y!"
			set "name=!name:Á=A!"
			set "name=!name:Ä=A!"
			set "name=!name:Â=A!"
			set "name=!name:?=A!"
			set "name=!name:Å=A!"
			set "name=!name:É=E!"
			set "name=!name:È=E!"
			set "name=!name:Ê=E!"
			set "name=!name:Ö=O!"
			set "name=!name:Ú=U!"
			set "name=!name:Ü=U!"
			set "name=!name:Ý=Y!"
			set "name=!name::=!"
			set "name=!name:?=!"
			set "name=!name:/= !"
		) else if "%%a"=="Published" (
			set "date=%%b"
			set "date=!date:?=x!"
			set "date=!date:~0,4!"
		) else if "%%a"=="Language" (
			set "lang=%%b"
			set "lang=!lang:/= !"
			set "lang=!lang::=!"
        ) else if "%%a"=="Players" (
			set "play=%%b"
			set "play=!play:/= !"
			set "play=!play::=!"
        ) else if "%%a"=="Control" (
			set "ctrl=%%b"
			set "ctrl=!ctrl:/= !"
			set "ctrl=!ctrl::=!"
		)
    )

    call :replace "name" "*" ""

    set "name=!new!"
    set "result=%name% (%date%) (%lang%) (%play%) (%ctrl%)"
    set /a "count=1"
    set test=0

    for /R %%f in (*.d64 *.nfo *.crt *.tap *.g64 *.d81 *.reu *.prg *.t64) do (
		set "file=%%f"
		set "ext=%%~xf"
		set "fichier=%result%!ext!"
		set "ficinc=%result%-!count!!ext!"

		If exist %D64%\!fichier! (
			set test=1
			set /a count=!count!-1
			set "ficind=%result%-!count!!ext!"
			move "%D64%\!fichier!" "%D64%\!ficind!"
			set /a count=!count!+1
		)

		if exist %D64%\!ficinc! (
			set test=1
		)

		if "!ext!" == ".NFO" (
			set test=0
			set /a count=!count!-1
		)

		if !test! == 1 (
			move "!file!" "%D64%\!ficinc!"
		) else (
			set test=0
			move "!file!" "%D64%\!fichier!"
		)

		set /a count=!count!+1
    )
exit /b
rem -----------------Fin Sous Routine NAME---------------


rem -----------------Sous Routine REPLACE---------------
:replace
    set "old=!%~1!"
    set "new="
    rem On compte le nombre de caractère de la variable en premier argument en entrée
    for /F "delims=:" %%c in ('(echo."!old!"^& echo.^)^|FindStr /O .') do set /A "$=%%c"
    for /L %%i in (0,1,%$%) do (
        If "!old:~%%i,1!" EQU "%~2" (
            set "new=!new!%~3"
        ) else (
            set "new=!new!!old:~%%i,1!"
		)
    )
    endlocal & set "new=!new!"
exit /b
rem -----------------Fin Sous Routine REPLACE---------------


rem ******************SOUS ROUTINES******************
:sroutines
    setlocal enableextensions
    setlocal enabledelayedexpansion
	pushd "%D64%"
		rem -----------------Sous Routine SUITE---------------
		:suite
			set "prevprefix="
			set "next=a"
			set /a current=1

			for %%f in ("*.g64" "*.d64")do (
				set "name=%%~nf"
				set "ext=%%~xf"
				set "prefix=!name:~0,-2!"
				set "suffix=!name:~-2!"
				set "lastchar=!suffix:~-1!"

				if "!suffix:~0,1!" equ "-" if "!lastchar!" geq "0" if "!lastchar!" leq "9" (
					if not defined prevprefix (
						set "prevprefix=!prefix!"
					)

					if "!prefix!" neq "!prevprefix!" (
						set "next=a"
						set /a current=1
						set "prevprefix=!prefix!"
					)

					set "newname=!prefix!_Disk!current!!next!!ext!"
					ren "%%~ff" "!newname!"

					if "!next!"=="a" (
						set "next=b"
					) else (
						set "next=a"
						set /a current=!current!+1
					)
				)
			)
		rem -----------------Fin Sous Routine SUITE---------------

		rem -----------------Sous Routine MINUS---------------
		:minus
			for %%f in (*.*) do (
				set "filename=%%~f"
				set "name=%%~nf"
				set "ext=%%~xf"

				for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
					set "ext=!ext:%%a=%%a!"
				)

				ren "!filename!" "!name!!ext!"
			)
		rem -----------------Fin Sous Routine MINUS--------------

		rem -----------------Sous Routine TRI---------------
		:tri
    		for %%f in (*.d64 *.nfo *.crt *.tap *.g64 *.d81 *.reu *.prg *.t64) do (
				set "nom=%%f"
				set "r=!nom:~0,1!" 2>nul

				if "!r!" GEQ "0" if "!r!" LEQ "9" set r=0

				for %%l in (' # $ ~ .) do if "!r!" == "%%l" set r=0

				md "!r!" 2> nul
				move "!nom!" .\"!r!"
			)
		rem -----------------Fin Sous Routine TRI---------------
	popd
	endlocal
rem ******************Fin SOUS ROUTINES******************
exit /b

:EOF
