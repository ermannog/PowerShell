REM http://internettrafficreport.com/

SET URI='http://internettrafficreport.com/gifs/tr_map_global.gif'
SET FILE='%~dp0Wallpaper.gif'

Powershell Invoke-WebRequest -Uri %URI% -UseDefaultCredentials -Proxy ([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy(%URI%) -ProxyUseDefaultCredentials -OutFile %FILE%
Powershell -ExecutionPolicy RemoteSigned -Command %~dp0Set-Wallpaper.ps1 %FILE%

PAUSE