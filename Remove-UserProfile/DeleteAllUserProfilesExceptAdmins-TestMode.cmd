powershell -ExecutionPolicy RemoteSigned -Command %~dp0\Remove-UserProfile.ps1 -UserName "*" -ExcludeUserName "Admin*" -WhatIf
pause 