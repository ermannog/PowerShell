<#
.SYNOPSIS
   Test web access through a proxy.
.DESCRIPTION
   This script try access to an Url through a proxy.
.PARAMETER Url
   Specifies the Url to test. This parameter is required.
.PARAMETER ProxyHost
   Specifies the host name or IP address of the proxy. This parameter is required.
.PARAMETER ProxyPort
   Specifies the port of the proxy. This parameter is required.
.PARAMETER UserName
   Specifies the User Name to authenticate with the proxy. This parameter is optional, if not specified will be used the credentials of the currently logged on user.
.PARAMETER Password
   Specifies the Password of User Name to authenticate with the proxy. This parameter is optional.
.EXAMPLE
   ./Test-WebProxy.ps1 -Url https://www.microsoft.com -ProxyHost proxy.contoso.com -ProxyPort 8080
   ./Test-WebProxy.ps1 -Url https://www.microsoft.com -ProxyHost proxy.contoso.com -ProxyPort 8080 -UserName usertest@contoso.com -Password P@assW0rd!
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    29/11/2018 
   Version: 1.0 
.LINK  
#>

Param(
  [Parameter(Mandatory=$True)]
  [string]$Url,
  [Parameter(Mandatory=$True)]
  [string]$ProxyHost,
  [Parameter(Mandatory=$True)]
  [int32]$ProxyPort,
  [string]$UserName,
  [string]$Password
)

Set-StrictMode -Version Latest

Try
{
  # Write Url info
  Write-Host "`nTesting web access through a proxy in progress...`n" -ForegroundColor White
  Write-Host "Url:`t" -NoNewline -ForegroundColor White
  Write-Host $Url -ForegroundColor Yellow
  
  # Create WebProxy object
  $proxy = New-Object System.Net.WebProxy($ProxyHost, $ProxyPort)
  $proxy.UseDefaultCredentials = [string]::IsNullOrEmpty($UserName)
  If (-Not [string]::IsNullOrEmpty($UserName)){
    $passwordSecureString = ConvertTo-SecureString $Password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential $UserName, $PasswordSecureString
    $Proxy.Credentials = $credential
  }

  # Write Proxy info
  Write-Host "Proxy:`t" -NoNewline -ForegroundColor White
  Write-Host $proxy.Address.AbsoluteUri -ForegroundColor Yellow
  Write-Host "User:`t" -NoNewline -ForegroundColor White
  If($proxy.UseDefaultCredentials)
  {
    Write-Host "Default credentials" -ForegroundColor Yellow
  }
  Else
  {
    Write-Host $UserName -ForegroundColor Yellow
  }

  # Write Host info
  Write-Host "Host:`t" -NoNewline -ForegroundColor White
  Write-Host $Env:ComputerName -ForegroundColor Yellow
  Write-Host "IPv4:`t" -NoNewline -ForegroundColor White
  $ipAddress = ((Get-NetIPConfiguration).IPv4Address | Select -Property @{Name='IPv4Address'; Expression={$_.IPAddress + "/" + $_.PrefixLength}} | Select -ExpandProperty IPv4Address) -Join ", "
  Write-Host $ipAddress -ForegroundColor Yellow
  

  # Create WebClient object
  $webClient = New-Object System.Net.WebClient
  $webClient.proxy = $proxy

  # Try access to url by proxy
  Write-Host "Result:`t" -NoNewline -ForegroundColor White

  Try
  {
    $content = $webClient.DownloadString($Url)
    Write-Host "Success" -ForegroundColor Green
  }
  Catch
  {
    Write-Host "Fail" -ForegroundColor Red
    Write-Host "`nError detail:" -ForegroundColor White
    Write-Host  $_.Exception.Message -ForegroundColor Red
  }
}
 Catch
{
  Write-Host "`nError detail:" -ForegroundColor White
  Write-Host  $_.Exception.Message -ForegroundColor Red
}