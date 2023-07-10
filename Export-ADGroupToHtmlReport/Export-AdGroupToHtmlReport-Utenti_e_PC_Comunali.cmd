@ECHO OFF
CLS

SET OUDN="OU=Utenti_e_PC_Comunali,DC=comune,DC=cuneo,DC=it"

FOR /f "delims=*" %%i in ('dsquery group %OUDN% -limit 0 -o samid') DO (
  powershell -ExecutionPolicy RemoteSigned -File %~dp0Export-AdGroupToHtmlReport.ps1 -GroupId %%~i -Note "Generazione massiva" -PathDirectoryReports "%~dp0Reports\Utenti_e_PC_Comunali"
)

Pause