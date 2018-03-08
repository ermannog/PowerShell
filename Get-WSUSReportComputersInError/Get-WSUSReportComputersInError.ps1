<#
.SYNOPSIS
   Get summary of computers with update in error.
.DESCRIPTION
   This script create a summary of computers with update in error and allows to send an html report by mail.
.PARAMETER CheckActive
   Check if computer is active by sending ICMP echo request packets ("pings").
.PARAMETER SendReportByMail
   Send an html report by mail of computers with update in error.
.PARAMETER SmtpServer
   Specifies the name of the SMTP server that sends the email message.
   The default value is the value of the $PSEmailServer preference variable. If the preference variable is not set and this parameter is omitted, the command fails.
.PARAMETER MailFrom
   Specifies the address from which the mail is sent. Enter a name (optional) and email address, such as Name <someone@example.com>. This parameter is required.
.PARAMETER MailTo
   Specifies the addresses to which the mail is sent. Enter names (optional) and the email address, such as Name <someone@example.com>. This parameter is required.
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    03/08/2018 
   Version: 1.3 
.LINK  
#>

Param(
  [switch]$CheckActive = $True,
  [switch]$SendReportByMail = $False,
  [string]$SmtpServer = [string]::Empty,
  [string]$MailFrom = [string]::Empty,
  [string]$MailTo = [string]::Empty
  )

Set-StrictMode -Version Latest


# Costants
$HeaderChars = 32


# Initializations
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()
$computerScope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
$updateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
$summariesComputerFailed = $wsus.GetSummariesPerComputerTarget($updateScope,$computerScope) | Where-Object FailedCount -NE 0 | Sort-Object FailedCount, UnknownCount, NotInstalledCount -Descending
$computers = Get-WsusComputer
$computersErrorEvents = $wsus.GetUpdateEventHistory([System.DateTime]::Today.AddDays(-7), [System.DateTime]::Today) | Where-Object ComputerId -ne Guid.Empty | Where-Object IsError -eq True
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
  $outputText = $computer.FullDomainName + " (IP:" + $computer.IPAddress + " - Wsus Id:" + $computerFailed.ComputerTargetId + ")"
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
  $outputText = " Last sync time".PadRight($HeaderChars) + ": " + ($computer.LastSyncTime).ToString()
  If ($computer.LastSyncTime -LE [System.DateTime]::Today.AddDays(-7)){
      Write-Host $outputText -ForegroundColor Magenta
      $reportHtmlBody +=  "<font color ='magenta'>" + $outputText + "</font><br>"
  }
  Else {
    Write-Host $outputText
    $reportHtmlBody += $outputText + "<br>"
  }


  # Last updated
  $outputText = " Last update".PadRight($HeaderChars) + ": " + ($computerFailed.LastUpdated).ToString()
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Active
  If ($CheckActive) {
    $outputText = " Active".PadRight($HeaderChars) + ": " + (Test-Connection $computer.FullDomainName -Count 1 -Quiet)
    Write-Host $outputText
    $reportHtmlBody += $outputText + "<br>"
  }

  # Separator
  $outputText = " " + "-" * ($HeaderChars - 2)
  Write-Host $outputText
  $reportHtmlBody += $outputText + "<br>"

  # Failed Updates
  $computerUpdatesFailed = ($wsus.GetComputerTargets($computerScope) | Where-Object Id -EQ $computerFailed.ComputerTargetId).GetUpdateInstallationInfoPerUpdate($updateScope) | Where UpdateInstallationState -EQ Failed

  $computerUpdateFailedIndex=0
  ForEach ($update In $computerUpdatesFailed) {
    If ($computerUpdateFailedIndex -EQ 0){
      $outputText = " Failed updates".PadRight($HeaderChars) + ": "
    }
    Else{
      $outputText = "".PadRight($HeaderChars+2)
    }

    $outputText += $wsus.GetUpdate($update.UpdateId).Title
    Write-Host $outputText
    $reportHtmlBody += $outputText + "<br>"

    $computerUpdateFailedIndex += 1
  }


  # Error events of the last 7 days
  $computerErrorEvents = $computersErrorEvents | Where-Object ComputerId -EQ $computerFailed.ComputerTargetId | Sort-Object CreationDate -Descending

  $computerErrorEventIndex=0
  ForEach ($event In $computerErrorEvents) {
    If ($computerErrorEventIndex -EQ 0){
      # Separator
      $outputText = " " + "-" * ($HeaderChars - 2)
      Write-Host $outputText
      $reportHtmlBody += $outputText + "<br>"

      $outputText = " Error events of the last 7 days".PadRight($HeaderChars) + ": "
    }
    Else{
      $outputText = "".PadRight($HeaderChars+2)
    }

    $outputText += ($event.CreationDate).ToString() + " " + $event.WsusEventId
    Write-Host $outputText -ForegroundColor Magenta
    $reportHtmlBody += "<font color ='magenta'>" + $outputText + "</font><br>"

    $computerErrorEventIndex += 1
  }


 }

# Sending the report by mail
If ($SendReportByMail){
  $mailSubject = "WSUS verifica computer con aggiornamenti in errore"

  $mailBody = $reportHtmlHeader
  $mailBody += "<pre>" + $reportHtmlBody + "</pre>"

  Send-MailMessage -To $MailTo -Subject $mailSubject -From $MailFrom -Body $mailBody -SmtpServer $SmtpServer -Encoding Default -BodyAsHtml

  Write-Host ("`n" + "Invio report sulla mail " + $MailTo + " eseguito.")
}