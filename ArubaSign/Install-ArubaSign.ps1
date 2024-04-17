Set-strictmode -version latest

# Impostazioni Costanti
$ProductName = "ArubaSign"
$SetupFileName = "ArubaSign-latest(standard).msi"
$UrlSetup = "https://updatesfirma.aruba.it/downloads/ArubaSign-latest(standard).msi"
$SetupArgs = "/qn /norestart"
$LogFileName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path) + "-" +$Env:UserName + ".log"

# Impostazioni Variabili
$PathFileSetup = Join-Path ($PSScriptRoot) ($SetupFileName)
$PathFileLog = Join-Path ($PSScriptRoot) ($LogFileName)
$Message = ""
$DownloadSetup = $false

Try {

  # Verifica prodotto installato
  $Message = "Verifica installazione $ProductName"
  Write-Host $Message  -ForegroundColor Green
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog

  $ProductInstalled = Get-WmiObject -Class Win32_Product | Where Name -eq $ProductName

  If (($ProductInstalled | Measure-Object).Count -eq 0)
  {
    # Verifica esitenza setup aggiornato
    If (-Not (Test-Path $PathFileSetup)) {
      $Message = "Il file di setup non presente localmente, occorre eseguirne il download."
      Write-Host $Message -ForegroundColor Green
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog
      $DownloadSetup = $True
    }
    Else {
      # Lettura data modifica del setup online
      $onlineSetupDate = [DateTime](Invoke-WebRequest -method "Head" $UrlSetup -UseBasicParsing | Select Headers -ExpandProperty Headers)["Last-Modified"]

      # Lettura data download del setup locale (la data di download corrisponde alla data di ultima modifica)
      $localSetupDate = (Get-ChildItem $PathFileSetup).LastWriteTime

      $DownloadSetup = ($onlineSetupDate -gt $localSetupDate)
    }

        
    # Download setup
    If ($DownloadSetup) {
      $Message = "Download $ProductName."
      Write-Host $Message -ForegroundColor Green
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog

      Invoke-WebRequest -URI $UrlSetup -OutFile $PathFileSetup
    }


    # Avvio Installazione
    $Message = "Avvio installazione $ProductName."
    Write-Host $Message -ForegroundColor Blue
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append

    #Write-Host $PathFileSetup
    Start-Process -FilePath $PathFileSetup -ArgumentList $SetupArgs -Wait

    $Message = "Installazione $ProductName completata."
    Write-Host $Message -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append
  }
  Else
  {
    $Message = "$ProductName è già installato!"
    Write-Host $Message -ForegroundColor Yellow
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append
  }
}
Catch{
    $Message = "Errore: $_"
    Write-Host $Message -ForegroundColor Red
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append
}