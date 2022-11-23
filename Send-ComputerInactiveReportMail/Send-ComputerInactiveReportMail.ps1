<#
.SYNOPSIS
   Send an email with the list of inactive computers.
.DESCRIPTION
   This script send an email with the list of inactive computers.
.PARAMETER DaysUntilComputerInactive
   Specifies the number of days until the computer is inactive. This parameter is optional, the default value is 180.
.PARAMETER ExcludePasswordNeverExpires
   Specifies to excludes computers with the PasswordNeverExpiresproperty set to True. This parameter is optional, the default value is True.
.PARAMETER From
   Specifies the address from which the mail is sent. Enter a name (optional) and email address, such as Name <someone@example.com>. This parameter is required.
.PARAMETER To
   Specifies the addresses to which the mail is sent. Enter names (optional) and the email address, such as Name <someone@example.com>. This parameter is required.
.PARAMETER SmtpServer
   Specifies the name of the SMTP server that sends the email message. This parameter is required.
.EXAMPLE
   ./Send-ComputerInactiveReportMail.ps1 -From %COMPUTERNAME%@contoso.com -To reports@contoso.com -SmtpServer mail.contoso.com
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    27/10/2022 
   Version: 1.0 
.LINK  
#>

Param(
  [uint32]$DaysUntilComputerInactive = 180,
  [bool]$ExcludePasswordNeverExpires = $True,
  [Parameter(Mandatory=$True)]
  [string]$MailFrom,
  [Parameter(Mandatory=$True)]
  [string]$MailTo,
  [Parameter(Mandatory=$True)]
  [string]$SmtpServer
)

Import-Module ActiveDirectory
Set-StrictMode -Version Latest

# Initializations
$encodingUTF8  = New-Object System.Text.utf8encoding

# Creation subject mail
$mailSubject = "Inactive computer accounts report from " + $DaysUntilComputerInactive + " days"

# Creation of the report body
$mailBody = "<p><b>Summary</b></p>"

# Search for computers that never logon from long time
# $ComputersInactive = Get-ADComputer -Filter {Enabled -eq $True} -Properties "Name", "OperatingSystem", "lastLogonTimestamp", "whenCreated", "PasswordExpired", "PasswordLastSet", | Select-Object -Property "Name", "OperatingSystem", "whenCreated", "PasswordExpired", @{Name="LastLogonDate";Expression={[DateTime]::FromFileTime($_."lastLogonTimestamp")}} | Where-Object {$_.LastLogonDate -le (Get-Date).AddDays(-$DaysUntilComputerInactive)}
$ComputersInactive = Get-ADComputer -Filter {Enabled -eq $True} -Properties "Name", "OperatingSystem", "lastLogonTimestamp", "whenCreated", "PasswordExpired", "PasswordLastSet", "PasswordNeverExpires"
$ComputersInactive = $ComputersInactive | Select-Object -Property "Name", "OperatingSystem", "whenCreated", "PasswordExpired", "PasswordLastSet", "PasswordNeverExpires", @{Name="LastLogonDate";Expression={[DateTime]::FromFileTime($_."lastLogonTimestamp")}}
$ComputersInactive = $ComputersInactive | Where-Object {$_.LastLogonDate -le (Get-Date).AddDays(-$DaysUntilComputerInactive) -or $_.PasswordExpired -eq $True}
If ($ExcludePasswordNeverExpires -eq $True) {
  $ComputersInactive = $ComputersInactive | Where-Object {$_.PasswordNeverExpires -eq $False}
}
$ComputersInactive = $ComputersInactive | Sort-Object -Property @{Expression = "LastLogonDate"; Descending = $false}, @{Expression = "whenCreated"; Descending = $false}, @{Expression = "Name"; Descending = $false}

# Creation of the report body
$mailBody += "<p>"
$mailBody += "<b>" + ($ComputersInactive | Measure-Object).Count + " Inactive computer accounts:</b>"

If ($ComputersInactive -ne 0) {
  ForEach ($computer in $ComputersInactive) {
    $mailBody += "<br>"
    $mailBody += "- Computer <b>" + $computer.Name  + "</b> ("
    $mailBody += "Last logon: " + (Get-Date -date $computer.LastLogonDate).Date.ToLongDateString() + " - "
    $mailBody += "OS: " + $computer.OperatingSystem + " - "
    $mailBody += "Creation date: " + (Get-Date -date $computer.whenCreated).Date.ToLongDateString() + " - "
    $mailBody += "Password expired date " + $computer.PasswordExpired + " - "
    $mailBody += "Password last set date " + $computer.PasswordLastSet + " - "
    $mailBody += "Password never expires flag " + $computer.PasswordNeverExpires + ")"
  }
}
$mailBody += "</p>"


# Create report CSV
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$ComputersInactiveCSVFile = Join-Path -Path $ScriptDir -ChildPath "ComputersInactive.csv"
$ComputersInactive | Export-CSV -NoTypeInformation $ComputersInactiveCSVFile


# Send mail to report mail
Try {
  Send-MailMessage -To $MailTo -Subject $mailSubject -From $MailFrom  -Body $mailBody -BodyAsHtml -SmtpServer $smtpServer -Encoding $encodingUTF8 -Attachments $ComputersInactiveCSVFile
  Write-Host ("`n" + "Inactive computer report mailing to " + $MailTo + " sent successfully.")
}
Catch {
  Write-Host ("`n" + "Inactive computer report mailing to " + $MailTo + " sending failed.")
  Write-Output $_
}
