powershell -ExecutionPolicy RemoteSigned -Command %~dp0Get-CSVReportFileInfo.ps1 "%Temp%" "%~dp0TempFileInfoReport.csv" -Recurse:$False -Force:$False 

pause