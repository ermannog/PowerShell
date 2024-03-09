#Requires -RunAsAdministrator

# Impostazioni Costanti
$ProductName = "Sophos Connect"
$ProductVersion = "2.2.90.1104"
$SetupFileName = "SophosConnect_2.2.90_(IPsec_and_SSLVPN).msi"

# Impostazione variabile per il nome del file di log
$LogFileName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path) + ".log"

# Impostazioni Variabili
$PathFileSetup = Join-Path ($PSScriptRoot) ($SetupFileName)
$PathFileLog = Join-Path ($PSScriptRoot) ($LogFileName)
$Message = ""


Try {

  # Verifica prodotto installato
  $Message = "Verifica installazione $ProductName Versione $ProductVersion"
  Write-Host $Message  -ForegroundColor Green
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog

  $ProductInstalled = Get-WmiObject -Class Win32_Product | Where Name -eq $ProductName | Where Version -eq $ProductVersion

  If (($ProductInstalled).Count -eq 0)
    {
    # Avvio Installazione
    $Message = "Avvio installazione $ProductName versione $ProductVersion."
    Write-Host $Message -ForegroundColor Blue
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append

    Write-Host $PathFileSetup
    Start-Process -FilePath msiexec.exe -ArgumentList @("/i", "$PathFileSetup", "/qn", "/Le!+", "$PathFileLog") -Wait
    

    $Message = "Installazione $ProductName versione $ProductVersion completata."
    Write-Host $Message -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append
  }
Else
  {
    $Message = "$ProductName versione $ProductVersion è già installato!"
    Write-Host $Message -ForegroundColor Yellow
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append
  }
}
Catch{
    $Message = "Errore: $_"
    Write-Host $Message -ForegroundColor Red
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append
}