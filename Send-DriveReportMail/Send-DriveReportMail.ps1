<#
.SYNOPSIS
   Send mail message with a report with info on size and free space of a drive.
.DESCRIPTION
   This script send mail message with a report with info on size and free space of a drive.
.PARAMETER From
   Specifies the address from which the mail is sent. Enter a name (optional) and email address, such as Name <someone@example.com>. This parameter is required.
.PARAMETER SmtpServer
   Specifies the name of the SMTP server that sends the email message. This parameter is required.
.PARAMETER To
   Specifies the addresses to which the mail is sent. Enter names (optional) and the email address, such as Name <someone@example.com>. This parameter is required.
.EXAMPLE
   ./Send-DriveReportMail.ps1 -Drive "E:" -From %COMPUTERNAME%@contoso.com -SmtpServer mail.contoso.com -To storage.alert@contoso.com
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    05/10/2018 
   Version: 1.0 
.LINK  
#>

Param(
  [Parameter(Mandatory=$True)]
  [string]$Drive,
  [Parameter(Mandatory=$True)]
  [string]$From,
  [Parameter(Mandatory=$True)]
  [string]$SmtpServer,
  [Parameter(Mandatory=$True)]
  [string]$To
)

Set-StrictMode -Version Latest


# Initializations
$DriveInfo = Get-WmiObject -Class Win32_logicaldisk -Filter ("DeviceID = '" + $Drive + "'")
$Size = [Math]::Round($DriveInfo.Size /1GB, 0)
$Free = [Math]::Round($DriveInfo.FreeSpace /1GB, 0)
$FreePercentage = [Math]::Round(($DriveInfo.FreeSpace * 100)/$DriveInfo.Size,0) 

# Creation of the report body
$reportHtmlBody = "<p>" + $Env:ComputerName  + " - Drive " + $Drive + "<br><br>"
$reportHtmlBody += "Disk size:  " + $Size.ToString("#,##0").PadLeft(8) + " GB<br>"
$reportHtmlBody += "Free space: <b>" + $Free.ToString("#,##0").PadLeft(8) + " GB (" + $FreePercentage + "%)</b></p>"

# Sending the report by mail
$mailSubject = "Report on the space available in drive '" + $Drive +"' of the computer " + $Env:ComputerName

#$mailBody = $reportHtmlHeader
$mailBody = "<pre>" + $reportHtmlBody + "</pre>"


Try {
  #  Send-MailMessage -To $To -Subject $mailSubject -From $From -Body $mailBody -SmtpServer $SmtpServer -Encoding Default -BodyAsHtml
  Send-MailMessage -To $To -From $From -SmtpServer $SmtpServer -Subject $mailSubject -Body $mailBody -BodyAsHtml
  Write-Host ("`n" + "Invio report sulla mail " + $To + " eseguito.")
}
Catch {
  Write-Host ("`n" + "Invio report sulla mail " + $To + " fallito.")
}