@ECHO OFF
CLS

SET OUDN="OU=Sales,DC=contoso,DC=com"

FOR /f "delims=*" %%i in ('dsquery group %OUDN% -limit 0 -o samid') DO (
  powershell -ExecutionPolicy RemoteSigned -File %~dp0Export-AdGroupToHtmlReport.ps1 -GroupId "%%~i" -Note "Generazione massiva" -PathDirectoryReports "%~dp0Reports\Sales"
  IF %errorlevel% NEQ 0 PAUSE
)

Pause
