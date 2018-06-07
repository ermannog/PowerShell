REM http://oiswww.eumetsat.org/IPPS/html/latestImages.html

SET URI='http://oiswww.eumetsat.org/IPPS/html/latestImages/EUMETSAT_MSG_RGBNatColour_CentralEurope.jpg'
SET FILE='%~dp0Wallpaper.jpg'

Powershell Invoke-WebRequest -Uri %URI% -UseDefaultCredentials -Proxy ([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy(%URI%) -ProxyUseDefaultCredentials -OutFile %FILE%
Powershell -ExecutionPolicy RemoteSigned -Command %~dp0Set-Wallpaper.ps1 %FILE%

PAUSE