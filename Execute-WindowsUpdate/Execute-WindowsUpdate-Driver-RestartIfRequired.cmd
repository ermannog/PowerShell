powershell.exe -ExecutionPolicy RemoteSigned -Command %~dp0Execute-WindowsUpdate.ps1 -UpdateType Driver -EndScriptOperation RestartIfRequired

pause