#Requires -RunAsAdministrator

<#
.SYNOPSIS
   Execute Windows Update on local computer, the session in which you are running the script must be started with elevated user rights (Run as Administrator).
.DESCRIPTION
   This script execute Windows Update on local computer.
.PARAMETER UpdateType
   Specifies specifies the type of the updates. This parameter is optional (the default value is Software).
   The allowed values are Software and Driver.
.PARAMETER EndScriptOperation
   Specifies specifies the operation to be performed at the end of the script. This parameter is optional (the default value is None).
   The allowed values are None, Restart, RestartIfRequired and Shutdown.
.PARAMETER LogFilePath
   Specifies the path of the log files. This parameter is optional (the default value is %SystemDrive%\Logs).
.PARAMETER LogFilesRetained
   Specifies number of log files retained. This parameter is optional (the default value is 30).
.PARAMETER SendLogByMail
   Specifies if send the log by mail. This parameter is optional (the default value is False).
.PARAMETER MailFrom
   Specifies the address from which the mail is sent. Enter a name (optional) and email address, such as Name <someone@example.com>.
.PARAMETER MailTo
   Specifies the addresses to which the mail is sent. Enter names (optional) and the email address, such as Name <someone@example.com>.
.PARAMETER SmtpServer
   Specifies the name of the SMTP server that sends the email message.
.EXAMPLE
   ./Execute-WindowsUpdate.ps1 ExecutionPolicy RemoteSigned -Command %~dp0Execute-WindowsUpdate.ps1 -SendLogByMail -MailFrom %COMPUTERNAME%@contoso.com -MailTo report@contoso.com -SmtpServer mail.contoso.com
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    02/26/2020 
   Version: 1.1 
.LINK  
#>

Param(
  [ValidateSet('Software','Driver')]
  [String]$UpdateType='Software',
  [ValidateSet('None','Restart','RestartIfRequired', 'Shutdown')]
  [String]$EndScriptOperation='None',
  [String]$LogFilePath="$env:SystemDrive\Logs",
  [UInt16]$LogFilesRetained=30,
  [Switch]$SendLogByMail=$FALSE,
  [String]$MailFrom,
  [String]$MailTo,
  [String]$SmtpServer
)

Set-Strictmode -Version Latest

# *** Window Update Settings (for testing purpose) ***
$enableDownload = $TRUE
$enableInstall = $TRUE
#$updatesLimit = -1 for install all the updates
$updatesLimit = -1
# ******************************

# *** Log Settings *************
$logFileNameSuffix = "LogInstallUpdates"
# ******************************

# *** Variables ****************
$flagRebootRequired = $FALSE
# ******************************

# *** Creazione Log Path e impostazione Log File Name
$logFileNameBase = $LogFilePath + "\" + $logFileNameSuffix
$logFile = $logFileNameBase + "-" + (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss") + ".txt"
if (!(Test-Path $LogFilePath)){
  New-Item $LogFilePath -type directory
}

# *** Ricerca Updates da Installare
Try {
  Write-Host -ForegroundColor Blue "Search $UpdateType updates..." 
  $updatesSearcher = New-Object -ComObject Microsoft.Update.Searcher
  $searchQuery = "Type='$UpdateType'"
  If ($UpdateType -eq 'Software'){
    $searchQuery = $searchQuery  + " AND IsInstalled=0 AND IsHidden=0"
  }
  $updatesPending = $updatesSearcher.Search($searchQuery)

  $updatesSelected = $updatesPending.Updates
  If ($updatesLimit -ne -1){
    $updatesSelected = $updatesSelected | Select-Object -First $updatesLimit
  }
} Catch {            
  Write-Warning "Error during search $UpdateType updates!"
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Errore durante ricerca aggiornamenti" | Out-File $logFile -append
  $_.Exception.Message | Out-File $logFile -append
}


# *** Analisi Elenco Updates da installare
If ($updatesPending.Updates.Count -eq 0){
  Write-Host -ForegroundColor Green "No $UpdateType updates found!"  
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Non sono stati trovati aggiornamenti $UpdateType da installare" | Out-File $logFile -append
}
Else {
  # Definizione della collezione degli update da scaricare
  $updatesDownloadCollection = New-Object -ComObject Microsoft.Update.UpdateColl

  # Definizione della collezione degli update da installare
  $updatesInstallCollection = New-Object -ComObject Microsoft.Update.UpdateColl

  # Scorrimento degli update da installare
  ForEach ($update In $updatesSelected) {
    Write-Host -ForegroundColor Green "Found $UpdateType update $($update.Title)"

    # Estrazione ID update da installare
    $updateID=$update.Identity.UpdateID

    # Log delle informazioni dell'update
     (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Analisi $UpdateType aggiornamento da installare" | Out-File $logFile -append
    "`t " + "Title: " + $update.Title | Out-File $logFile -append
    "`t " + "ID: " + $update.Identity.UpdateID | Out-File $logFile -append
    "`t " + "Mandatory: " + $update.IsMandatory.ToString() | Out-File $logFile -append
    "`t " + "Restart is required: " + $update.RebootRequired.ToString() | Out-File $logFile -append
    "`t " + "Maximum download size: " + $update.MaxDownloadSize + " bytes" | Out-File $logFile -append
    "`t " + "Description: " + $update.Description | Out-File $logFile -append
    If ($update.DownloadPriority -eq 1){
      "`t " + "Priority: Low" | Out-File $logFile -append
    }
    ElseIf ($update.DownloadPriority -eq 2){
      "`t " + "Priority: Normal" | Out-File $logFile -append
    }
    ElseIf ($update.DownloadPriority -eq 3){
      "`t " + "Priority: High" | Out-File $logFile -append
    }

    # Accettazione EULA
    Try {
      If (-Not $update.EulaAccepted){
        Write-Host -ForegroundColor Yellow "Accepting EULA update..."
        $update.AcceptEula()
        "`t " + "EULA accettata" | Out-File $logFile -append
      }
    } Catch {            
      Write-Warning "Error during accept EULA update!"
     (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Errore durante accettazione EULA aggiornamento" | Out-File $logFile -append
     $_.Exception.Message | Out-File $logFile -append
    }


    # Ricerca Item Update
    $updateIDSearcher = $updatesSearcher.Search("UpdateID='$updateID'")
    $updateIDUpdates = $updateIDSearcher.Updates
    $updateIDItem = $updateIDUpdates.Item(0)


    # Aggiunta dell'update alla collezione degli update da scaricare
    If ($update.IsDownloaded){
      Write-Host -ForegroundColor Yellow "Update already downloaded!"
      "`t " +  "Aggiornamento scaricato" | Out-File $logFile -append
    }
    Else {
      Write-Host -ForegroundColor Yellow "Add update to the download queue!"
      "`t " + "Aggiornamento da scaricare" | Out-File $logFile -append
      $updatesDownloadCollection.Add($updateIDItem) | out-null
    }


    # Aggiunta dell'update alla collezione degli update da installare
    Write-Host -ForegroundColor Yellow "Add update to the install queue!"
    $updatesInstallCollection.Add($updateIDItem) | out-null
  }


  # Avvio Download Aggiornamenti
  If ($updatesDownloadCollection.Count -eq 0){
    Write-Host -ForegroundColor Green "No $UpdateType updates to download found!"
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Non sono stati trovati aggiornamenti $UpdateType da scaricare" | Out-File $logFile -append
  }
  ElseIf ($enableDownload) {
    Try {
      Write-Host -ForegroundColor Blue "Downloading $($updatesDownloadCollection.Count) $UpdateType updates..."
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Avvio download " + $updatesDownloadCollection.Count + " aggiornamenti $UpdateType" | Out-File $logFile -append
      $updateSession = New-Object -ComObject Microsoft.Update.Session
      $updatesDownloader = $updateSession.CreateUpdateDownloader()
      $updatesDownloader.Updates = $updatesDownloadCollection
      $updatesDownloader.Download()
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Download aggiornamenti $UpdateType eseguito" | Out-File $logFile -append
      Write-Host -ForegroundColor Green "Download $UpdateType updates completed!"
    } Catch {            
      Write-Warning "Error during download update!"
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Errore durante download aggiornamento $UpdateType" | Out-File $logFile -append
      $_.Exception.Message | Out-File $logFile -append
    }
  }
  Else{
    Write-Host -ForegroundColor Red "$($updatesDownloadCollection.Count) $UpdateType updates must be downloaded!"
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Necessario dowload di " + $updatesDownloadCollection.Count + " aggiornamenti $UpdateType" | Out-File $logFile -append   
  }


  # Installazione Aggiornamenti
  If ($updatesInstallCollection.Count -eq 0){
    Write-Host -ForegroundColor Green "No $UpdateType updates to install found!"
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Non sono stati trovati aggiornamenti $UpdateType da installare" | Out-File $logFile -append
  }
  ElseIf ($enableInstall) {
    Try {
      Write-Host -ForegroundColor Blue "Installing $($updatesInstallCollection.Count) $UpdateType updates..."
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Avvio installazione " + $updatesInstallCollection.Count + " aggiornamenti $UpdateType" | Out-File $logFile -append
      $updatesInstaller = New-Object -ComObject Microsoft.Update.Installer
      $updatesInstaller.Updates = $updatesInstallCollection
      $installResult = $updatesInstaller.Install()
      If ($installResult.RebootRequired){
        $flagRebootRequired = $TRUE
      }
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Installazione aggiornamenti $UpdateType eseguita" | Out-File $logFile -append
      Write-Host -ForegroundColor Green "Install $UpdateType updates completed!"
    } Catch {            
      Write-Warning "Error during install $UpdateType update!"
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Errore durante installazione aggiornamento $UpdateType" | Out-File $logFile -append
      $_.Exception.Message | Out-File $logFile -append
    }
  }
  Else{
    Write-Host -ForegroundColor Red "$($updatesInstallCollection.Count) $UpdateType updates must be installed!"
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Necessaria installazione di " + $updatesInstallCollection.Count + " aggiornamenti $UpdateType" | Out-File $logFile -append
  }
}

  # Invio Log File
  If ($SendLogByMail){
    Write-Host -ForegroundColor Blue "Sending log by mail..."
    $mailSubject = "Installazione aggiornamenti $UpdateType computer $($env:computername) [" + (Get-WmiObject -Class Win32_OperatingSystem).Caption + "]"
    $mailBody = Get-Content $logFile | Out-String
    
    If ($EndScriptOperation -eq 'Restart'){
      $mailBody = $mailBody + "`nIl sistema verrà riavviato"
    }
    ElseIf ($flagRebootRequired -and ($EndScriptOperation -eq 'RestartIfRequired')){
      $mailBody = $mailBody + "`nIl sistema verrà riavviato a seguito dell'installazione degli aggiornamenti che richiedono il riavvio"
    }
    ElseIf ($EndScriptOperation -eq 'Shutdown'){
      $mailBody = $mailBody + "`nIl sistema verrà arrestato"
    }

    Send-MailMessage -To $MailTo -Subject $mailSubject -From $MailFrom -Body $mailBody -SmtpServer $smtpServer -Encoding Default
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Invio log tramite mail eseguito" | Out-File $logFile -append
  }

  # Eliminazione log file obsoleti
  $logFiles = Get-ChildItem $LogFilePath PipelineVariable item | Where {$item.psIsContainer -eq $false -and $item.FullName -like ($logFileNameBase + "*")} | Sort FullName
  $LogFilesCount = ($logFiles | Measure-Object).Count
  If ($LogFilesCount -gt $LogFilesRetained){
    Write-Host -ForegroundColor Blue "Remove old log files..."
    For ($i = 1; $i -le $LogFilesCount - $LogFilesRetained; $i++) {
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Eliminazione log file " + $logFiles[$i-1].FullName | Out-File $logFile -append
      Remove-Item $logFiles[$i-1].FullName | Out-File $logFile -append
    }
  }

  # Esecuzione riavvio o arresto 
  If ($EndScriptOperation -eq 'Restart'){
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Riavvio computer" | Out-File $logFile -append
    Restart-Computer -Force
  }
  ElseIf ($flagRebootRequired -and ($EndScriptOperation -eq 'RestartIfRequired')){
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Riavvio computer necessario a seguito dell'installazione degli aggiornamenti" | Out-File $logFile -append
    Restart-Computer -Force
  }
  ElseIf ($EndScriptOperation -eq 'Shutdown'){
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Arresto computer" | Out-File $logFile -append
    Stop-Computer -Force
  }
