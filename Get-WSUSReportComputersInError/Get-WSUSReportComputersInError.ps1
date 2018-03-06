<#
.SYNOPSIS
   Get summary of computers with update in error and send an html report by mail.
.DESCRIPTION
   This script create a summary of computers with update, if necessary is possible change the Settings section for check is the computer is active and send an html report by mail.
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    03/06/2017 
   Version: 1.0 
.LINK  
#>

Set-StrictMode -Version Latest

# Settings
$checkActive = $True
$sendReportByMail = $True
$smtpServer = "mailserver.domain.ext"
$mailFrom = "wsusserver@domain.ext"
$mailTo = "alert@domain.ext"

# Costants
$HeaderChars = 32

# Initializations
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()
$computerScope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
$updateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
$summariesComputerFailed = $wsus.GetSummariesPerComputerTarget($updateScope,$computerScope) | Where-Object FailedCount -NE 0 | Sort-Object FailedCount -Descending | Sort-Object UnknownCount -Descending
$computers = Get-WsusComputer
$outputText = ""


# Creating the report header
If ($summariesComputerFailed -EQ 0){
  $outputText = "No computers were found on the WSUS server (" + $wsus.ServerName + ") with updates in error!"
  Write-Host ("`n" + $outputText) -ForegroundColor Green
  $reportHtmlHeader = "<font color ='green'><b>" + $outputText + "</b></font>"
}
Else {
  $outputText = [string]($summariesComputerFailed).Count + " computers were found on the WSUS server (" + $wsus.ServerName + ") with failed updates!"
  Write-Host ("`n" + $outputText) -ForegroundColor Red
  $reportHtmlHeader = "<font color ='red'><b>" + $outputText + "</b></font>"
}


# Creation of the report for computers with updates in error
$reportHtmlBody = "<br>"
ForEach ($computerFailed In $summariesComputerFailed) {
  $computer = $computers | Where-Object Id -eq $computerFailed.ComputerTargetId

  $reportHtmlBody += "<br>"
  
  # FullDomainName e IP
  $outputText = $computer.FullDomainName + " (IP:" + $computer.IPAddress + ")"
  Write-Host ("`n" + $outputText) -ForegroundColor Yellow
  $reportHtmlBody += "<b>" + $outputText + "</b><br>"

  # Hardware info
  $outputText = " Hardware info".PadRight($HeaderChars) + ": " + $computer.Make + " " + $computer.Model
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Operating system
  $outputText = " Operating system".PadRight($HeaderChars) + ": " + $computer.OSDescription
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Separator
  $outputText = " " + "-" * ($HeaderChars - 2)
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Update failed
  $outputText = " Update failed".PadRight($HeaderChars) + ": " + $computerFailed.FailedCount
  Write-Host $outputText -ForegroundColor Red
  $reportHtmlBody += "<font color ='red'>" + $outputText + "</font><br>"

  # Update unknown
  $outputText = " Update unknown".PadRight($HeaderChars) + ": " + $computerFailed.UnknownCount
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Update not installed
  $outputText = " Update not installed".PadRight($HeaderChars) + ": " + $computerFailed.NotInstalledCount
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Update installed pending reboot
  $outputText = " Update installed pending reboot".PadRight($HeaderChars) + ": " + $computerFailed.InstalledPendingRebootCount
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Update downloaded
  $outputText = " Update downloaded".PadRight($HeaderChars) + ": " + $computerFailed.DownloadedCount
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Update installed
  $outputText = " Update installed".PadRight($HeaderChars) + ": " + $computerFailed.InstalledCount
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Separator
  $outputText = " " + "-" * ($HeaderChars - 2)
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Last sync result
  $outputText = " Last sync result".PadRight($HeaderChars) + ": " + $computer.LastSyncResult
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Last sync time
  $outputText = " Last sync time".PadRight($HeaderChars) + ": " + $computer.LastSyncTime
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Last updated
  $outputText = " Last update".PadRight($HeaderChars) + ": " + $computerFailed.LastUpdated
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Active
  If ($checkActive) {
    $outputText = " Active".PadRight($HeaderChars) + ": " + (Test-Connection $computer.FullDomainName -Count 1 -Quiet)
    Write-Host $outputText
    $reportHtmlBody += $outputText + "<br>"
  }
}

# Sending the report by mail
If ($sendReportByMail){
  $mailSubject = "WSUS verifica computer con aggiornamenti in errore"

  $mailBody = $reportHtmlHeader
  $mailBody += "<pre>" + $reportHtmlBody + "</pre>"

  Send-MailMessage -To $mailTo -Subject $mailSubject -From $mailFrom -Body $mailBody -SmtpServer $smtpServer -Encoding Default -BodyAsHtml

  Write-Host ("`n" + "Invio report sulla mail " + $mailTo + " eseguito.")
}