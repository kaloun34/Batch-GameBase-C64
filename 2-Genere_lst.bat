rem ### Tonton ###
rem # (03/12/2022)

rem 21/02/2023
rem Reprise Script

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
set /a Compt=0
set /a Compt2=0
set /a Compt3=1

echo "Génération des fichiers .lst en cours"
echo ..........

call :log %LOGFILE% "%script% Log"
call :log %LOGERROR% "%script% Log Error"

pushd "%D64%"
    for /f "delims=" %%d in ('dir /ad/b/s') do (
        cd "%%d"
        rem: Il n'y a pas nécéssairement des fichiers dans les dossiers parcourues

        set "found="
        if exist "*.d64" set found=true
        if exist "*.t64" set found=true
        if exist "*.g64" set found=true
        if exist "*.tap" set found=true

        if defined found (
            dir "*.d64";"*.g64";"*.t64";"*.tap" /a /B /O:GEN > filelist.txt 2>>"%LOGERROR%"
            del *.lst 2>nul

            rem: pour chaque ligne du fichier filelist.txt
            for /f "delims=" %%l in (filelist.txt) do (
				set "ligne=%%l"
				call:lst "!ligne!" >>"%LOGFILE%" 2>>"%LOGERROR%"
			)
            del filelist.txt 2>>"%LOGERROR%"
            cd ..
        )
    )
popd
goto:EOF
rem exit
:: **********************FIN************************



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


:: -----------------Routine LST----------------
:lst
    rem: Traitement du fichier filelist.txt contenent tous les fichiers C64
    set "nomfic=%~1"
	set "nomfic=!nomfic:^^^&=^&!"

    rem: Coupe le nom de fichier au délimiteur _ (ex: kkwet_Disk1a.d64  %%i=kkwet)

    for /F "tokens=1 delims=_" %%i in ("!nomfic!") do set nomlst="%%i".lst
    
    for /L %%x in (0,1,2) do (
        if  %%x=="2" do (
            set /a Compt=%Compt%-%%x
        )
        set /a Compt=%Compt+%%x
        if %Compt%==%Compt2% (
            if "!nomlst!"=="!nomlstold!" (
                set /a Compt3+=1
                if %Compt3% gtr 1 (
                    echo !nomfic! >> "!nomlst!"
                    goto :else
                )
                echo !nomold! >> "!nomlst!"
                echo !nomfic! >> "!nomlst!"
            )
        )
    )
    ::Sous-Routine else
    :else
        if "!nomlst!" NEQ "!nomlstold!" (set /a Compt3=1)
		set nomold=!nomfic!
		set nomlstold=!nomlst!
		set Compt2=%Compt%
	:: Fin else
exit /b
:: -----------------Fin Routine LST----------------

:EOF
