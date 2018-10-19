<#
.SYNOPSIS
   Send mail message with a report generate by a query on Sql Sever.
.DESCRIPTION
   This script send mail message with a report generate by a query on Sql Sever.
.PARAMETER QueryFile
   Specifies a text file that contains the sql query. This parameter is required.
.PARAMETER ServerInstance
   Specifies the name of an instance of the Database Engine. For default instances, only specify the computer name: MyComputer. For named instances, use the format ComputerName\InstanceName. This parameter is optional (the default value is local computer).
.PARAMETER Database
   Specifies the name of a database. This parameter is required.
.PARAMETER Subject
   Specifies the subject of the mail. This parameter is required.
.PARAMETER From
   Specifies the address from which the mail is sent. Enter a name (optional) and email address, such as Name <someone@example.com>. This parameter is required.
.PARAMETER SmtpServer
   Specifies the name of the SMTP server that sends the email message. This parameter is required.
.PARAMETER To
   Specifies the addresses to which the mail is sent. Enter names (optional) and the email address, such as Name <someone@example.com>. This parameter is required.
.PARAMETER OutputToBody
   Specifies if the query output will be inserted in the body of the mail. This parameter is optional (the default value is True).
.PARAMETER LineWidth
   Specifies the number of characters in each line of output. This parameter is optional (the default value is 160).
.PARAMETER AttachCSV
   Specifies specifies if the query output will be attached as a csv file. This parameter is optional (the default value is False).
.EXAMPLE
   ./Send-SqlQuerytMail.ps1 -QueryFile 'query.sql' -ConnectionString 'Data Source=localhost;Initial Catalog=AdventureWorks;Integrated Security=SSPI' -Subject 'Report'  -From %COMPUTERNAME%@contoso.com -SmtpServer mail.contoso.com -To sqlreport@contoso.com
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    16/10/2018 
   Version: 1.0 
.LINK  
#>

Param(
  [Parameter(Mandatory=$True)]
  [string[]]$QueryFiles,
  [string]$ServerInstance = $env:computername,
  [Parameter(Mandatory=$True)]
  [string]$Database,
  [Parameter(Mandatory=$True)]
  [string]$Subject,
  [Parameter(Mandatory=$True)]
  [string]$From,
  [Parameter(Mandatory=$True)]
  [string]$SmtpServer,
  [Parameter(Mandatory=$True)]
  [string]$To,
  [Switch]$OutputToBody=$True,
  [uint32]$LineWidth=[uint32]160,
  [switch]$AttachCSV=$False
)

Set-StrictMode -Version Latest

# Set Variables
$erroFileName = [System.IO.Path]::GetFileNameWithoutExtension(($PSCommandpath).ToString()) + ".err"
$errorFile = Join-Path -Path $PSScriptRoot -ChildPath $erroFileName
$attachmentsFolder = Join-Path -Path $PSScriptRoot -ChildPath "Attachments"
$attachments = @()


# Create attachments folder for attach
If ($AttachCSV -And -Not(Test-Path $attachmentsFolder)) {
      New-Item -ItemType Directory -Force -Path $attachmentsFolder
}

# Execute query
$queryOutput = [String]::Empty
Try {
  ForEach ($queryFile In $QueryFiles) {
    $queryOutput += "<b>Result of the query " + [System.IO.Path]::GetFileName($queryFile) + ":</b>"
    $queryOutput += "`n"

    # Export to CSV
    Try {
      If ($AttachCSV) {
        $attachFileName = [System.IO.Path]::GetFileNameWithoutExtension($queryFile) + ".csv"
        $attachFile = Join-Path -Path $attachmentsFolder -ChildPath $attachFileName

        Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -InputFile $QueryFile -ErrorAction Stop | Export-Csv -Path $attachFile -NoTypeInformation -ErrorAction Stop

        $attachments += $attachFile
      }
    }
    Catch {
      Write-Host ("`n" + "Error during export query csv." + "`n" + $_.Exception.Message)
      $queryOutput += "`n" + $_.Exception.Message + "`n"
      "[" + (Get-Date).ToString() + "]`r`n" + $_.Exception.Message + "`r`n`r`n" | Out-File $errorFile -Append
    }
 
    # Query Output
    Try{
      If ($OutputToBody){
        $queryOutput += Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -InputFile $QueryFile -ErrorAction Stop | Format-Table -AutoSize | Out-String -Width $LineWidth
      }
      Else {
        $queryOutput += "See the attach " + $attachFileName
      }
    }
    Catch {
      Write-Host ("`n" + "Error during query execution." + "`n" + $_.Exception.Message)
      $queryOutput += "`n" + $_.Exception.Message + "`n"
      "[" + (Get-Date).ToString() + "]`r`n" + $_.Exception.Message + "`r`n`r`n" | Out-File $errorFile -Append
    }
    $queryOutput += "`n"
  }
}
Catch {
  Write-Host ("`n" + "Error during execution." + "`n" + $_.Exception.Message)
  $queryOutput += "`n" + $_.Exception.Message + "`n"
  "[" + (Get-Date).ToString() + "]`r`n" + $_.Exception.Message + "`r`n`r`n" | Out-File $errorFile -Append
}

# Sending the report by mail
$mailBody = "<pre>" + $queryOutput + "</pre>"

Try {
  If ($AttachCSV) {
    Send-MailMessage -To $To -From $From -SmtpServer $SmtpServer -Subject $Subject -Body $mailBody -BodyAsHtml -Attachments $attachments -ErrorAction Stop
  }
  Else {
    Send-MailMessage -To $To -From $From -SmtpServer $SmtpServer -Subject $Subject -Body $mailBody -BodyAsHtml -ErrorAction Stop
  }
  
  Write-Host ("`n" + "Sending query output to the email " + $To + " executed.")
}
Catch {
  Write-Host ("`n" + "Error during sending query output to the email." + "`n" + $_.Exception.Message)
  "[" + (Get-Date).ToString() + "]`r`n" + $_.Exception.Message + "`r`n`r`n" | Out-File $errorFile -Append
}