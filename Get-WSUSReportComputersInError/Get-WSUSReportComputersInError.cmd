REM *** Avvio task di notifica ***
PowerShell -ExecutionPolicy RemoteSigned -File %~dp0WSUS-SendComputersInErrorNotification.ps1 %LogFilePath%

