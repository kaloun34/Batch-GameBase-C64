
rem ### Tonton ###
rem # (09/08/2021)
rem #
rem # 09/02/2023
rem # Reprise du script

rem *********************DEBUT************************
@echo off
setlocal enableextensions
set "MIST=%cd%"
set "GB64=C:\GameBase\Commodore 64"
set "D64=%MIST%\D64"
set "TEMP=%D64%\temp"
set "ZIP=%GB64%\Games"
set "TOOLS=%GB64%\Emulators"

cls
rmdir /Q /S %D64% >nul 2>%MIST%\fichier_log.txt
mkdir %TEMP% >nul 2>>%MIST%\fichier_log.txt

echo "Opération en cours"
echo ..........

pushd "%ZIP%"
	for /f "delims=" %%d In ('dir /ad/b/s  "." ') do (
		cd "%%d"
		for %%z in (*.zip) do (
			7z.exe -y x "%%z" -o"%TEMP%" >nul 2>>%MIST%\fichier_log.txt
			pushd %TEMP%
				for %%x in (*.t64) do (
					"%TOOLS%"\c1541.exe -format "fromt64,01" d64 "%%~nx.d64" -tape "%%x" >nul 2>>%MIST%\fichier_log.txt
					del "%%x"
				)

				for /f "delims=" %%a in ('dir /a:-d /o:n /b *.d64 *.nfo *.crt *.tap *.g64 *.d81 *.reu *.prg *.t64') do (call :suppr "%%a")
		        call :name
			popd
            rem appel des sous-routines SUITE, MINUS et TRI en delayedexpansion
            call :sroutines
		)
		cd..
	)
popd

rmdir /S /Q %TEMP% >nul 2>>%MIST%\fichier_log.txt
rem exit
rem **********************FIN************************

GOTO :FIN

rem -----------------Sous Routine SUPPR----------------
:suppr
    rem Suppression du ! dans le nom de fichier qui est bloquant sur un delayedexpansion
    set "newname=%~nx1"
    set "newname=%newname:!=x%"
    ren %1 "%newname%" >nul 2>>%MIST%\fichier_log.txt
rem -----------------Fin Sous Routine SUPPR----------------
GOTO :FIN

rem -----------------Sous Routine NAME---------------
:name
setlocal enabledelayedexpansion
    CHCP 1252 >nul

    rem Extraction des informations du fichier version.nfo de chaque jeux
    for /f "tokens=1,* delims=: " %%a in ('type version.nfo ^| findstr /C:"Name:" /C:"Published:" /C:"Language:" /C:"Players:" /C:"Control:"') do (
	    if "%%a"=="Name" (
    	    set "name=%%b"
    	    set "name=!name:/= !"
    	    set "name=!name:Å=A!"
    	    set "name=!name:Ä=A!"
    	    set "name=!name:ä=a!"
            set "name=!name:Ö=O!"
    	    set "name=!name:ö=o!"
    	    set "name=!name:ü=u!"
			set "name=!name:Ü=U!"
			set "name=!name:Ú=U!"
			set "name=!name:ú=u!"
    	    set "name=!name::=!"
    	    set "name=!name:?=!"
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
		    move "%D64%\!fichier!" "%D64%\!ficind!" >nul 2>>%MIST%\fichier_log.txt
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
		    move "!file!" "%D64%\!ficinc!" >nul 2>>%MIST%\fichier_log.txt
	    ) else (
		    set test=0
		    move "!file!" "%D64%\!fichier!" >nul 2>>%MIST%\fichier_log.txt
	    )

	    set /a count=!count!+1
    )
rem -----------------Fin Sous Routine NAME---------------
GOTO :FIN

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
rem -----------------Fin Sous Routine REPLACE---------------
GOTO :FIN

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
            ren "%%~ff" "!newname!" >nul 2>>%MIST%\fichier_log.txt

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

        ren "!filename!" "!name!!ext!" >nul 2>>%MIST%\fichier_log.txt
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
	    move "!nom!" .\"!r!" >nul 2>>%MIST%\fichier_log.txt
    )
rem -----------------Fin Sous Routine TRI---------------
popd
endlocal
rem ******************Fin SOUS ROUTINES******************
GOTO :FIN

:FIN
