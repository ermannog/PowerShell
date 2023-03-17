@ECHO OFF
powershell -ExecutionPolicy RemoteSigned -Command %~dp0Create-ReportVMs.ps1 -OutputFile '"%PUBLIC%\Desktop\Report VMs.txt"'