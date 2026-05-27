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
$InstallSetup = $false

Try {


  # Verifica esistenza setup aggiornato
  $Message = "Verifica esistenza setup aggiornato."
  Write-Host $Message -ForegroundColor Green
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog


  If (-Not (Test-Path $PathFileSetup)) {
    $Message = "Il file di setup non presente localmente, occorre eseguirne il download."
    Write-Host $Message -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append
    $DownloadSetup = $True
  }
  Else {
    # Lettura data modifica del setup online
    $onlineSetupDate = [DateTime](Invoke-WebRequest -method "Head" $UrlSetup -UseBasicParsing | Select Headers -ExpandProperty Headers)["Last-Modified"]
    # Lettura dimensione del setup online
    $onlineSetupContentLength = [Int64](Invoke-WebRequest -method "Head" $UrlSetup -UseBasicParsing | Select Headers -ExpandProperty Headers)["Content-Length"]

    # Lettura data download del setup locale (la data di download corrisponde alla data di ultima modifica)
    $localSetupDate = (Get-ChildItem $PathFileSetup).LastWriteTime
    # Lettura dimensione download del setup locale
    $localSetupDateLength = (Get-ChildItem $PathFileSetup).Length

    $DownloadSetup = ($onlineSetupDate -gt $localSetupDate) -or ($onlineSetupContentLength -ne $localSetupDateLength)
  }
          
  # Download setup
  If ($DownloadSetup) {
    $Message = "Download $ProductName."
    Write-Host $Message -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append

    Invoke-WebRequest -URI $UrlSetup -OutFile $PathFileSetup
  }
  

  # Verifica prodotto installato
  $Message = "Verifica installazione $ProductName"
  Write-Host $Message  -ForegroundColor Green
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append

  $ProductInstalled = Get-WmiObject -Class Win32_Product | Where Name -eq $ProductName


  If (($ProductInstalled | Measure-Object).Count -eq 0){
    $Message = "$ProductName non è installato."
    Write-Host $Message -ForegroundColor Yellow
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append

    $InstallSetup = $True
  }
  Else
  {
    # Verifica versione del setup
    $shellApp = New-Object -ComObject Shell.Application
    $folderObject = $shellApp.NameSpace((Get-Item $PathFileSetup).DirectoryName)
    $fileObject = $folderObject.Items().Item((Get-Item $PathFileSetup).Name)
    $subjectPropertyIndex=22
    $subjectPropertyValue = $propertyValue = $folderObject.GetDetailsOf($fileObject, $subjectPropertyIndex)
    $productInstalledVersion = $ProductInstalled.Version

    If (-not $subjectPropertyValue.EndsWith($ProductInstalled.Version)){
      $Message = "La versione installata ($productInstalledVersion) è diversa da quella del setup ($subjectPropertyValue)."
      Write-Host $Message -ForegroundColor Yellow
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append

      $InstallSetup = $True
    }
  }

  If ($InstallSetup)
  {
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