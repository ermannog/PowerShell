@ECHO OFF
SETLOCAL

REM *** Impostazioni
SET PathFileProfile=%~dp0ProfileSSLVPNFileName.pro
SET ProfileName=ProfileSSLVPNName
SET PathDirSophosConnect=C:\Program Files (x86)\Sophos\Connect
SET PathFileLog=%~dp0%~n0.log

REM *** Controllo esistenza sccli.exe
ECHO Check Sophos Connect installation>"%PathFileLog%"
IF NOT EXIST "%PathDirSophosConnect%\sccli.exe" (
  ECHO Sophos Connect non installed.
  GOTO ERROR
)

REM *** Controllo servizio scvpn avviato
ECHO Check service SCVPN running>>"%PathFileLog%"
SET COUNTER=0

:CHECKSERVICE
SET /A COUNTER=COUNTER+1
SC QUERY scvpn | FIND /i "RUNNING" > NUL
IF ERRORLEVEL 1 (
  ECHO Check %COUNTER%: Not Runnig>>"%PathFileLog%"
  IF %COUNTER% EQU 3 GOTO ERROR
  TIMEOUT /T 30 > NUL
  GOTO CHECKSERVICE
) ELSE (
  ECHO Service SCVPN Running>>"%PathFileLog%"
)

REM *** Controllo esistenza profilo
ECHO Check connection profile>>"%PathFileLog%"
"%PathDirSophosConnect%\sccli" list | findstr /i /R  "%ProfileName%" > nul
IF %errorlevel% == 0 (
  ECHO Profile already present>>"%PathFileLog%"
) ELSE (
  "%PathDirSophosConnect%\sccli" add -f "%PathFileProfile%">>"%PathFileLog%"
  IF %ERRORLEVEL% NEQ 1 GOTO ERROR
  ECHO Profile added>>"%PathFileLog%"
)

:END
EXIT

:ERROR
ECHO Error during add profile!>>"%PathFileLog%"