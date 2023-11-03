::rem ### Tonton ###
::rem # (09/08/2021)
::rem #
::rem # 09/02/2023
::rem # Reprise du script

::rem *********************DEBUT************************
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
	::rem Parcours du dossier GameBase, décompression fichier par ficher avec conversion si besoin en D64
	for /f "delims=" %%d In ('dir /ad/b/s  "." ') do (
		cd "%%d" >nul 2>>"%LOGERROR%"
		for %%z in (*.zip) do (
			7z.exe -y x "%%z" -o"%TEMP%" >nul 2>>"%LOGERROR%"
			pushd %TEMP%
				for %%x in (*.t64) do (
					"%TOOLS%"\c1541.exe -format "fromt64,01" d64 "%%~nx.d64" -tape "%%x" >nul 2>>"%LOGERROR%"
					del "%%x" >nul 2>>"%LOGERROR%"
				)

				::rem Appel routine SUPPR pour suppresion d'un éventuel ! dans le nom de fichier
				for /f "delims=" %%a in ('dir /a:-d /o:n /b *.d64 *.crt *.tap *.g64 *.d81 *.reu *.prg *.t64') do ( call :suppr "%%a" >nul 2>>"%LOGERROR%" )

				::rem Appel routine NAME (renomme fichiers du jeu en fonction de son nfo )
				call :name >nul 2>>"%LOGERROR%"
			popd

            ::rem: Appel des sous-routines SUITE, MINUS et TRI en delayedexpansion
				 : - SUITE pour les jeux sur plusieurs D7
				 : - MINUS pour passer les extensions de fichier en minuscule
				 : - TRI des fichiers par la 1ere lettre du nom de fichier
			call :sroutines >nul 2>>"%LOGERROR%"
		)
		cd..
	)
popd

rmdir /S /Q %TEMP%
exit
::rem **********************FIN************************



: -----------------Routine LOG----------------
	::rem Utilisation : call kkwett >>"%LOGFILE%" 2>>"%LOGERROR%"
		: call kkwett >nul 2>>"%LOGERROR%"
		: call kkwett >>"%LOGFILE%" >nul
:log
set "FILE=%~1"
echo %~2 > "%FILE%"
echo. >> "%FILE%" & echo ================= >> "%FILE%"
echo Date: %date% %time% >> "%FILE%" & echo ================= >> "%FILE%"
echo. >> "%FILE%"
exit /b
: -----------------Fin Routine LOG----------------


: -----------------Sous SUPPR----------------
:suppr
    ::rem Suppression du ! dans le nom de fichier qui est bloquant sur un delayedexpansion
    set "oldname=%~nx1"
    set "newname=%oldname:!=x%"
    if "%newname%" neq "%~nx1" ( ren "%oldname%" "%newname%" )
exit /b
: -----------------Fin Routine SUPPR----------------


: -----------------Routine NAME---------------
:name
setlocal enabledelayedexpansion
    CHCP 1252
    ::rem Extraction des informations du fichier version.nfo de chaque jeux
    for /f "tokens=1,* delims=: " %%a in ('type version.nfo ^| findstr /C:"Name:" /C:"Published:" /C:"Language:" /C:"Players:" /C:"Control:"') do (
		if "%%a"=="Name" (
			set "name=%%b"
			set "name=!name:à=a!"
			set "name=!name:á=a!"
			set "name=!name:â=a!"
			set "name=!name:Â=A!"
			set "name=!name:Á=A!"
			set "name=!name:ã=a!"
			set "name=!name:ä=a!"
			set "name=!name:Ä=A!"
			set "name=!name:å=a!"
			set "name=!name:Å=A!"
			set "name=!name:ç=c!"
			set "name=!name:è=e!"
			set "name=!name:È=E!"
			set "name=!name:é=e!"
			set "name=!name:É=E!"
			set "name=!name:ê=e!"
			set "name=!name:Ê=E!"
			set "name=!name:í=i!"
			set "name=!name:ò=o!"
			set "name=!name:ó=o!"
			set "name=!name:ô=o!"
			set "name=!name:ö=o!"
			set "name=!name:Ö=O!"
			set "name=!name:ø=o!"
			set "name=!name:ù=u!"
			set "name=!name:ú=u!"
			set "name=!name:Ú=U!"
			set "name=!name:û=u!"
			set "name=!name:ü=u!"
			set "name=!name:Ü=U!"
			set "name=!name:ý=y!"
			set "name=!name:Ý=Y!"
			set "name=!name:ÿ=y!"
			set "name=!name:ß=ss!"
			set "name=!name:æ=ae!"
			set "name=!name:=!"
			set "name=!name:?=!"
			set "name=!name:/=-!"
		) else if "%%a"=="Published" (
			set "date=%%b"
			set "date=!date:?=x!"
			set "date=!date:~0,4!"
		) else if "%%a"=="Language" (
			set "lang=%%b"
			set "lang=!lang:/=-!"
			set "lang=!lang:=!"
        ) else if "%%a"=="Players" (
			set "play=%%b"
			set "play=!play:/=-!"
			set "play=!play:=!"
        ) else if "%%a"=="Control" (
			set "ctrl=%%b"
			set "ctrl=!ctrl:/=-!"
			set "ctrl=!ctrl:=!"
		)
    )

		: -----------------Sous Routine ASTERIX---------------
		set /a pos=0
			::rem: Suppresion des éventuelles * dans le nom du jeu
				 : qui ne passe pas avec la commande précédente de substitution même avec un échappement
		:asterix
			set /a plusone=%pos%+1
			if "!name:~%pos%,1!"=="*" set name=!name:~0,%pos%!!name:~%plusone%!
			set /a pos=%pos%+1
			if not "!name:~%pos%,1!"=="" goto :asterix
		: -----------------Fin Sous Routine ASTERIX-------------

		: -----------------Sous Routine MAJUS---------------
			::rem Dans certain nfo, le nom du jeu commence par une minuscule
		:majus

				set "fname=%name:~0,1%"
				set "rname=%name:~1%"

				for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
					set "fname=!fname:%%a=%%a!"
				)
		: -----------------Fin Sous Routine MAJUS--------------

    set "result=!fname!%rname% (%date%) (%lang%) (%play%) (%ctrl%)"
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
: -----------------Fin Routine NAME---------------


::rem ******************SOUS ROUTINES******************
:sroutines
    setlocal enableextensions
    setlocal enabledelayedexpansion
	pushd "%D64%"
		: -----------------Sous Routine SUITE---------------
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
		: -----------------Fin Sous Routine SUITE---------------

		: -----------------Sous Routine MINUS---------------
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
		: -----------------Fin Sous Routine MINUS--------------

		: -----------------Sous Routine TRI---------------
		:tri
			for %%f in (*.nfo) do (
				set "nom=%%f"
				set "r=!nom:~0,1!" 2>nul
				set "nom=!nom:~0,-4!" 2>nul

				if "!r!" GEQ "0" if "!r!" LEQ "9" set r=0

				for %%l in (' # $ ~ .) do if "!r!" == "%%l" set r=0

				: -----------------Sous Routine GENRE---------------
					:genre
					for /f "tokens=1,* delims=: " %%a in ('type "!nom!".nfo ^| findstr /C:"Genre:"') do (
						set "genre=%%b"
						set "genre=!genre:/=-!"
						set "genre=!genre:=!"
					)

					if "!genre:-=!"=="!genre!" (
						set "folder=!genre!"
					) else (
						for /f "tokens=1,* delims=-" %%a in ("!genre!") do (
							set "genre=%%a"
							set "sgenre=%%b"
							set "genre=!genre:~0,-1!"
							set "sgenre=!sgenre:~1!"
							set "folder=!genre!\!sgenre!"
						)
					)
				: -----------------Fin Sous Routine GENRE---------------
				md "!folder!\!r!" 2>nul
				move "!nom!*.*" ".\!folder!\!r!"
			)
		: -----------------Fin Sous Routine TRI---------------
	popd
	endlocal
::rem ******************Fin SOUS ROUTINES******************
exit /b

:EOF
