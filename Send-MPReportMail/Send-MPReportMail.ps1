<#
.SYNOPSIS
   Send mail message if Windows Defender has detected malware threats or is not update or if the services are not active.
.DESCRIPTION
   This script send mail message if Windows Defender has detected malware threats or is not update or if the services are not active.
.PARAMETER From
   Specifies the address from which the mail is sent. Enter a name (optional) and email address, such as Name <someone@example.com>. This parameter is required.
.PARAMETER SmtpServer
   Specifies the name of the SMTP server that sends the email message. This parameter is required.
.PARAMETER Subject
   Specifies the subject of the email message. This parameter is required.
.PARAMETER To
   Specifies the addresses to which the mail is sent. Enter names (optional) and the email address, such as Name <someone@example.com>. This parameter is required.
.PARAMETER SendMailAsAnonymous
   Specifies that the email will be sent with the credentials of a fictitious user anonymous. This parameter is optional (the default value is False).
.PARAMETER AlertOnSignatureNotUpdateFromDays
   Specifies after how many days if the antivirus signatures are out of date the report will be sent. This parameter is optional (the default value is 2).
.PARAMETER AlertOnThreatDetectionLastDays
   Specifies how many days will be considered when searching for detected threads to send the report. This parameter is optional (the default value is 30).
.PARAMETER AlertOnAttemptsUntrustedAppsWriteDetectionLastDays
   Specifies how many days will be considered when searching for detected Attempts by untrusted apps to write in Controlled folders to send the report. This parameter is optional (the default value is 7).
.EXAMPLE
   ./Send-MPThreatDetectionMail.ps1 -From %COMPUTERNAME%@contoso.com -SmtpServer mail.contoso.com -To malware.alert@contoso.com
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    22/08/2023 
   Version: 1.4
.LINK  
#>

Param(
  [Parameter(Mandatory=$True)]
  [string]$From,
  [Parameter(Mandatory=$True)]
  [string]$SmtpServer,
  [Parameter(Mandatory=$True)]
  [string]$To,
  [switch]$SendMailAsAnonymous=$False,
  [uint32]$AlertOnSignatureNotUpdateFromDays=2,
  [uint32]$AlertOnThreatDetectionLastDays=30,
  [uint32]$AlertOnAttemptsUntrustedAppsWriteDetectionLastDays=7
)

Set-StrictMode -Version Latest

# Initializations
$sendmail=$False
$padRightChars = 35
$reportHtmlBodyCheckText=""
$mailSubject = "Windows Defender Report from " +  $Env:ComputerName
$ScriptVersion = ((((Get-Help -Full $PSCommandPath).alertSet.alert.Text) -Split '\r?\n').Trim() | Select-String -Pattern 'Version:').ToString().Replace("Version:","").Trim()


Enum ThreatStatusIDValues
{
 Unknown = 0
 Detected = 1
 Cleaned = 2
 Quarantined = 3
 Removed = 4
 Allowed = 5
 BlockedCleanFailed = 6
 QuarantineFailed = 102
 RemoveFailed = 103
 AllowFailed = 104
 Abondoned = 105
 BlockedFailed = 107
}

# OS info
$osInfo = Get-CimInstance -Class CIM_OperatingSystem
$osVersion = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

$reportHtmlBody = "<p>"
$reportHtmlBody += "<b>" + "Host name:".PadRight($PadRightChars) + $Env:ComputerName +"</b><br>"
$reportHtmlBody += "Operating system:".PadRight($PadRightChars) + $osInfo.Caption + " " + $osInfo.OSArchitecture +"<br>"
$reportHtmlBody += "Operating system version:".PadRight($PadRightChars) + $osVersion.CurrentMajorVersionNumber + "." + $osVersion.CurrentBuildNumber + "." + $osVersion.UBR + "<br>"
$reportHtmlBody += "Last Boot Up Time:".PadRight($PadRightChars) + [string]$osInfo.LastBootUpTime + "<br>"
$reportHtmlBody += "Script version:".PadRight($PadRightChars) + $ScriptVersion + "<br>"
$reportHtmlBody += "</p>"


# Antimalware info initializations
$winDefendServiceInfo = Get-Service -Name "WinDefend"
$mpComputerStatus = Get-MPComputerStatus
$reportHtmlBody += "<p>"

# Antimalware info - Check Service Enabled
$reportHtmlBodyCheckText = ($winDefendServiceInfo.DisplayName + ":").PadRight($PadRightChars) + $winDefendServiceInfo.Status + "<br>"
If ($winDefendServiceInfo.Status -ne "Running"){
  $reportHtmlBody += "<font color ='red'><b>" + $reportHtmlBodyCheckText + "</b></font>"
  $sendmail=$True
}
Else {
  $reportHtmlBody += $reportHtmlBodyCheckText
}

# Antimalware info - Check Antivirus Enabled
$reportHtmlBodyCheckText = "Antivirus Enabled:".PadRight($PadRightChars) + $mpComputerStatus.AntivirusEnabled + "<br>"
If ($mpComputerStatus.AntivirusEnabled -eq $False){
  $reportHtmlBody += "<font color ='red'><b>" + $reportHtmlBodyCheckText + "</b></font>"
  $sendmail=$True
}
Else {
  $reportHtmlBody += $reportHtmlBodyCheckText
}

# Antimalware info - Check Antispyware Enabled
$reportHtmlBodyCheckText = "Antispyware Enabled:".PadRight($PadRightChars) + $mpComputerStatus.AntispywareEnabled + "<br>"
If ($mpComputerStatus.AntispywareEnabled -eq $False){
  $reportHtmlBody += "<font color ='red'><b>" + $reportHtmlBodyCheckText + "</b></font>"
  $sendmail=$True
}
Else {
  $reportHtmlBody += $reportHtmlBodyCheckText
}

# Antimalware info - Check Network Inspection System Enabled
$reportHtmlBodyCheckText = "Network Inspection System Enabled:".PadRight($PadRightChars) + $mpComputerStatus.AntispywareEnabled + "<br>"
If ($mpComputerStatus.NISEnabled -eq $False){
  $reportHtmlBody += "<font color ='red'><b>" + $reportHtmlBodyCheckText + "</b></font>"
  $sendmail=$True
}
Else {
  $reportHtmlBody += $reportHtmlBodyCheckText
}

# Antimalware info - Check On Access Protection Enabled
$reportHtmlBodyCheckText = "On Access Protection Enabled:".PadRight($PadRightChars) + $mpComputerStatus.AntispywareEnabled + "<br>"
If ($mpComputerStatus.OnAccessProtectionEnabled -eq $False){
  $reportHtmlBody += "<font color ='red'><b>" + $reportHtmlBodyCheckText + "</b></font>"
  $sendmail=$True
}
Else {
  $reportHtmlBody += $reportHtmlBodyCheckText
}

# Antimalware info - Check "Antivirus Signature Last Updated
$reportHtmlBodyCheckText = "Antivirus Signature Last Updated:".PadRight($PadRightChars) + $mpComputerStatus.AntivirusSignatureLastUpdated + "<br>"
If ((New-TimeSpan -Start (Get-Date) -End $mpComputerStatus.AntivirusSignatureLastUpdated).Days -ge $AlertOnSignatureNotUpdateFromDays){
  $reportHtmlBody += "<font color ='red'><b>" + $reportHtmlBodyCheckText + "</b></font>"
  $sendmail=$True
}
Else {
  $reportHtmlBody += $reportHtmlBodyCheckText
}

# Antimalware info - Antivirus Signature Versions
$reportHtmlBody += "Antivirus Signature Version:".PadRight(35) + $mpComputerStatus.AntivirusSignatureVersion  + "<br>"
$reportHtmlBody += "</p>"


# Threats info initializations
$threatsDetection = Get-MpThreatDetection | Where-Object { $_.InitialDetectionTime -ge (Get-Date).AddDays(-$AlertOnThreatDetectionLastDays) }
$threatsCount = ($threatsDetection | Measure-Object).Count
$reportHtmlBody += "<p>"

# Threats info - Check threat last days
$reportHtmlBodyCheckText = ("Threats found in the last " + $AlertOnThreatDetectionLastDays + " days:").PadRight($PadRightChars) + $threatsCount + "<br>"
If ($threatsCount -ne 0){
  $reportHtmlBody += "<font color ='red'><b>" + $reportHtmlBodyCheckText + "</b></font>"
  $sendmail=$True
}
Else {
  $reportHtmlBody += $reportHtmlBodyCheckText
}
$reportHtmlBody += "</p>"

# Threats list
ForEach ($threat In $threatsDetection)
{
  $reportHtmlBody += "<p>"
  $reportHtmlBody += ("Thread Initial Detection Time:").PadRight($PadRightChars) + $threat.InitialDetectionTime + "<br>"
  $reportHtmlBody += ("Thread Name:").PadRight($PadRightChars) + (Get-MpThreat -ThreatID $threat.ThreatID).ThreatName + "<br>"
  $reportHtmlBody += ("Thread Domain User:").PadRight($PadRightChars) + $threat.DomainUser + "<br>"
  $reportHtmlBody += ("Thread Process Name:").PadRight($PadRightChars) + $threat.ProcessName + "<br>"
  $reportHtmlBody += ("Thread Status:").PadRight($PadRightChars) + [System.Enum]::GetName([ThreatStatusIDValues], $threat.ThreatStatusID) + "<br>"
  ForEach($resource in $threat.Resources)
  {
    $reportHtmlBody += ("Thread Resource:").PadRight($PadRightChars) + $resource + "<br>"
  }
  
  $reportHtmlBody += "</p>"
}

# Attempts by untrusted apps to write in Controlled folders info initializations
$event1123Logs = Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational" | Where-Object { $_.Id -eq 1123 -and $_.TimeCreated -ge (Get-Date).AddDays(-$AlertOnAttemptsUntrustedAppsWriteDetectionLastDays)}
$event1123LogsCount = ($event1123Logs | Measure-Object).Count
$reportHtmlBody += "<p>"

# Attempts by untrusted apps to write in Controlled folders info info - Check threat last days
$reportHtmlBodyCheckText = "Attempts by untrusted apps to write in Controlled folders found in the last " + $AlertOnAttemptsUntrustedAppsWriteDetectionLastDays + " days: " + $event1123LogsCount + "<br>"
If ($event1123LogsCount -ne 0){
  $reportHtmlBody += "<font color ='red'><b>" + $reportHtmlBodyCheckText + "</b></font>"
  $sendmail=$True
}
Else {
  $reportHtmlBody += $reportHtmlBodyCheckText
}
$reportHtmlBody += "</p>"

# Attempts by untrusted apps to write in Controlled folders info list
ForEach ($event1123Log In $event1123Logs)
{
  $reportHtmlBody += "<p>"
  $reportHtmlBody += ("Attempt Detection Time:").PadRight($PadRightChars) + $event1123Log.TimeCreated + "<br>"
  $reportHtmlBody += ("Attempt User:").PadRight($PadRightChars) + $event1123Log.properties[5].value + "<br>"
  $reportHtmlBody += ("Attempt Process Name:").PadRight($PadRightChars) + $event1123Log.properties[7].value + "<br>"
  $reportHtmlBody += ("Attempt Path:").PadRight($PadRightChars) + $event1123Log.properties[6].value + "<br>"

  $reportHtmlBody += "</p>"
}

# Send Mail
If ($sendmail -eq $True) {
  $mailBody = "<pre>" + $reportHtmlBody + "</pre>"

  Try {
    If ($SendMailAsAnonymous -eq $True){
      $anonymousUser = "anonymous"
      $anonymousPassword = ConvertTo-SecureString $anonymousUser -AsPlainText -Force
      $anonymousCredential = New-Object System.Management.Automation.PSCredential($anonymousUser, $anonymousPassword)
      Send-MailMessage -To $To -From $From -SmtpServer $SmtpServer -Subject $mailSubject -Body $mailBody -BodyAsHtml -Credential $anonymousCredential
    }
    Else{
      Send-MailMessage -To $To -From $From -SmtpServer $SmtpServer -Subject $mailSubject -Body $mailBody -BodyAsHtml
    }
    Write-Host ("`n" + "Send report on mail " + $To + " successfull.")
  }
  Catch {
    Write-Host ("`n" + "Invio report sulla mail " + $To + " failed.")
  }
}