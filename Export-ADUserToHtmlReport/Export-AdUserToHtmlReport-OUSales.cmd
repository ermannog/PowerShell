@ECHO OFF
CLS

SET OUDN="OU=Sales,DC=contoso,DC=com"

FOR /f "delims=*" %%i in ('dsquery user %OUDN% -limit 0 -o samid') DO (
  powershell -ExecutionPolicy RemoteSigned -File %~dp0Export-AdUserToHtmlReport.ps1 -UserId %%~i -Note "Generazione massiva" -PathDirectoryReports "%~dp0Reports\Sales"
)

Pause