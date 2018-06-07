REM http://internettrafficreport.com/

SET ImageMagickConvertFile="%~dp0Tools\ImageMagick-7.0.7-38-portable-Q16-x64\Convert"
SET WallpaperFile=%~dp0Wallpaper.png

REM Download Global Map
SET URI='http://internettrafficreport.com/gifs/tr_map_global.gif'
SET FILE='%~dp0tr_map_global.gif'
Powershell Invoke-WebRequest -Uri %URI% -UseDefaultCredentials -Proxy ([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy(%URI%) -ProxyUseDefaultCredentials -OutFile %FILE%

REM Download Global Traffic
SET URI='http://internettrafficreport.com/graphs/tr_main_s1.gif'
SET FILE='%~dp0tr_main_s1.gif'
Powershell Invoke-WebRequest -Uri %URI% -UseDefaultCredentials -Proxy ([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy(%URI%) -ProxyUseDefaultCredentials -OutFile %FILE%

REM Download Global Response Time
SET URI='http://internettrafficreport.com/graphs/tr_main_r1.gif'
SET FILE='%~dp0tr_main_r1.gif'
Powershell Invoke-WebRequest -Uri %URI% -UseDefaultCredentials -Proxy ([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy(%URI%) -ProxyUseDefaultCredentials -OutFile %FILE%

REM Download Global Packet Loss
SET URI='http://internettrafficreport.com/graphs/tr_main_p1.gif'
SET FILE='%~dp0tr_main_p1.gif'
Powershell Invoke-WebRequest -Uri %URI% -UseDefaultCredentials -Proxy ([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy(%URI%) -ProxyUseDefaultCredentials -OutFile %FILE%

REM Download Europe Traffic
SET URI='http://internettrafficreport.com/graphs/tr_europe_s1.gif'
SET FILE='%~dp0tr_europe_s1.gif'
Powershell Invoke-WebRequest -Uri %URI% -UseDefaultCredentials -Proxy ([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy(%URI%) -ProxyUseDefaultCredentials -OutFile %FILE%

REM Download Europe Response Time
SET URI='http://internettrafficreport.com/graphs/tr_europe_r1.gif'
SET FILE='%~dp0tr_europe_r1.gif'
Powershell Invoke-WebRequest -Uri %URI% -UseDefaultCredentials -Proxy ([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy(%URI%) -ProxyUseDefaultCredentials -OutFile %FILE%

REM Download Europe Packet Loss
SET URI='http://internettrafficreport.com/graphs/tr_europe_p1.gif'
SET FILE='%~dp0tr_europe_p1.gif'
Powershell Invoke-WebRequest -Uri %URI% -UseDefaultCredentials -Proxy ([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy(%URI%) -ProxyUseDefaultCredentials -OutFile %FILE%

REM Build Wallpaper Image with ImageMagick
%ImageMagickConvertFile% -size 1152x864 xc:black ^
tr_map_global.gif -geometry +341+300 -composite ^
tr_main_s1.gif -geometry +0+0 -composite ^
tr_main_r1.gif -geometry +401+0 -composite ^
tr_main_p1.gif -geometry +802+0 -composite ^
tr_europe_s1.gif -geometry +0+684 -composite ^
tr_europe_r1.gif -geometry +401+684 -composite ^
tr_europe_p1.gif -geometry +802+684 -composite ^
%WallpaperFile%

Powershell -ExecutionPolicy RemoteSigned -Command %~dp0Set-Wallpaper.ps1 %WallpaperFile%

PAUSE