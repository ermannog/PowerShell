REM https://umbra.nascom.nasa.gov/newsite/images.html

SET URI='https://umbra.nascom.nasa.gov/images/latest_aia_211.gif'
SET FILE='%~dp0Wallpaper.gif'

Powershell [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri %URI% -Proxy ([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy(%URI%) -UseDefaultCredentials -ProxyUseDefaultCredentials -OutFile %FILE%
Powershell -ExecutionPolicy RemoteSigned -Command %~dp0Set-Wallpaper.ps1 %FILE%

PAUSE