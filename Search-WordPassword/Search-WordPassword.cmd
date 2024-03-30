@ECHO OFF
powershell -ExecutionPolicy RemoteSigned -Command %~dp0%~n0.ps1 %~dp0Protected.docx %~dp0Passwords.txt
Pause