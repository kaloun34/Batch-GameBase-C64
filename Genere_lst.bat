rem ### Tonton ###
rem # (03/12/2022)

rem 21/02/2023
rem Reprise Script

rem *********************DEBUT************************
@echo off
cls

setlocal enableextensions
setlocal enabledelayedexpansion
set "MIST=%CD%"
set "D64=%MIST%\D64"
set "script=%~n0"
set "LOGFILE=%MIST%\%script%.log"
set "LOGERROR=%MIST%\%script%_errors.log"
set /A NBC=0& ::Nombre de caractère du fichier
set /A NBC2=0
set /A NBCold=1

call :log %LOGFILE% "%script% Log"
call :log %LOGERROR% "%script% Log Error"

pushd "%D64%"
	for /f "delims=" %%a In ('dir /ad/b/s') do (
		cd "%%a"
		2>nul dir *.d64;*.g64;*.t64 /A /B /O:GEN >filelist.txt
		for /f "tokens=* delims=" %%a in (filelist.txt) do echo %%a>>filelist2.txt

		if exist "filelist2.txt" (
			del *.lst 2>nul
			for /F "delims=" %%l in (filelist2.txt) do call:lst "%%l" >>"%LOGFILE%" 2>>"%LOGERROR%"
			del filelist2.txt
		)
		del filelist.txt
		cd ..
	)
popd
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
set NFIC=%~1& ::Nom du fichier
echo "%NFIC%" | find "_" 2>nul
if %errorlevel%==0 (goto :genere)
rem -----------------Fin Sous Routine LST----------------
goto :FIN

rem -----------------Sous Routine GENERE----------------
:genere
for /F "tokens=1,2 delims=_" %%i in ("%NFIC%") do set NLST=%%i.lst

::Compte le nombre de caractere du nom du fichier
rem for /f "tokens=1,* delims=[,]" %%C in ('"%comspec%" /u /c echo %NFIC%|more|find /n /v ""') do set /a NBC=%%C-4
pause
call :Getnbcarac "%NFIC%"
setlocal enableDelayedExpansion
pause
for /L %%x in (0,1,2) do (
    set /A NBC=NBC+%%x
    if  %%x=="2" do (set /A NBC=NBC-5)

    if %NBC%==%NBC2% (
        if "%NLST%"=="%NLSTold%" (
            set /A NBCold+=1
            if %NBCold% gtr 1 (
                echo !NFIC!>> "%NLST%"
				goto :else
			)
            echo !NFICold!>> "%NLST%"
            echo !NFIC!>> "%NLST%"
        )
    )
)

:else
if "%NLST%" NEQ "%NLSTold%" (set /A NBCold=1)
set NFICold=%NFIC%
set NLSTold=%NLST%
set NBC2=%NBC%
rem --------------Fin Sous Routine GENERE----------------
goto :FIN

rem -----------------Sous Routine NB CARAC----------------
:Getnbcarac
setlocal enableDelayedExpansion
set "str=%~1"
set "/a len=0"
:loop
if "!str:~%len%,1!" neq "" set /a "len+=1" & goto :loop
echo len: %len%
endlocal & set NBC=%len%-4
exit /b
rem -----------------fin Sous Routine NB CARAC--------------
goto :FIN

:FIN
