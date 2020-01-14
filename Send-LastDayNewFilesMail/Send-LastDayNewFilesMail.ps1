<#
.SYNOPSIS
   Send mail message with a report with info on size of the new files of a path.
.DESCRIPTION
   This script send mail message with a report on size of the new files of a path.
.PARAMETER Path
   Specifiy the path where find the new files
.PARAMETER From
   Specifies the address from which the mail is sent. Enter a name (optional) and email address, such as Name <someone@example.com>. This parameter is required.
.PARAMETER SmtpServer
   Specifies the name of the SMTP server that sends the email message. This parameter is required.
.PARAMETER To
   Specifies the addresses to which the mail is sent. Enter names (optional) and the email address, such as Name <someone@example.com>. This parameter is required.
.PARAMETER AttachCSVReport
   Specifies specifies if the new files list will be attached as a csv file. This parameter is optional (the default value is True).
.EXAMPLE
   ./Send-LastDayNewFilesMail.ps1 -Path "E:" -From %COMPUTERNAME%@contoso.com -SmtpServer mail.contoso.com -To storage.alert@contoso.com
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    01/10/2020 
   Version: 1.0 
.LINK  
#>


Param(
  [Parameter(Mandatory=$True)]
  [string]$Path,
  [Parameter(Mandatory=$True)]
  [string]$From,
  [Parameter(Mandatory=$True)]
  [string]$SmtpServer,
  [Parameter(Mandatory=$True)]
  [string]$To,
  [Switch]$AttachCSVReport = $True
)

Set-StrictMode -Version Latest

# Function for convert the lenght of the file in a friendly size 
# Reference: https://blogs.technet.microsoft.com/pstips/2017/05/20/display-friendly-file-sizes-in-powershell/
Function Get-FriendlySize {
    Param($Bytes)

    $sizes='Bytes,KB,MB,GB,TB,PB,EB,ZB' -Split ','
    for($i=0; ($Bytes -ge 1kb) -and 
        ($i -lt $sizes.Count); $i++) {$Bytes/=1kb}
    $N=2; if($i -eq 0) {$N=0}
    "{0:N$($N)} {1}" -f $Bytes, $sizes[$i]
}

#$ItemsInfoSortedCSVFile = Join-Path -Path $PSScriptRoot -ChildPath "NewFiles.csv"
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$ItemsInfoSortedCSVFile = Join-Path -Path $ScriptDir -ChildPath "LastDayNewFiles.csv"

$Items = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.CreationTime -gt (Get-Date).AddDays(-1) }
$ItemsInfo = $Items | Select-Object @{Name="FilePath"; Expression={$_.FullName}}, @{Name="Size"; Expression={$_.Length}}
$ItemsInfoSorted = $ItemsInfo | Sort-Object -Property @{Expression={$_.Size}; Descending=$true}, @{Expression={$_.FilePath}; Descending=$false}
$TotalSize = ($ItemsInfoSorted | Measure-Object -Property Size -Sum).Sum


# Creation of the report body
$reportHtmlBody = "<p>New files in the path '" + $Path + "' of the computer " + $Env:ComputerName + "<br><br>"
$reportHtmlBody += "Total size: " + (Get-FriendlySize $TotalSize) + "<br><br>"

ForEach ($itemInfo In $ItemsInfoSorted) {
  $reportHtmlBody += (Get-FriendlySize $itemInfo.Size).PadLeft(10) + "  " + $itemInfo.FilePath + "<br>"
} 

# Sending the report by mail
$mailSubject = "Report on new files in path '" + $Path +"' of the computer " + $Env:ComputerName

#$mailBody = $reportHtmlHeader
$mailBody = "<pre>" + $reportHtmlBody + "</pre>"


# Create report CSV
If ($AttachCSVReport){
  $ItemsInfoSorted | Export-CSV -NoTypeInformation $ItemsInfoSortedCSVFile
}

Try {
  If ($AttachCSVReport){
    Send-MailMessage -To $To -From $From -SmtpServer $SmtpServer -Subject $mailSubject -Body $mailBody -BodyAsHtml -Attachments $ItemsInfoSortedCSVFile
  }
  Else {
    Send-MailMessage -To $To -From $From -SmtpServer $SmtpServer -Subject $mailSubject -Body $mailBody -BodyAsHtml
  }
  Write-Host ("`n" + "Invio report sulla mail " + $To + " eseguito.")
}
Catch {
  Write-Host ("`n" + "Invio report sulla mail " + $To + " fallito.")
}