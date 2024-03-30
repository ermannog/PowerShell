<#
.SYNOPSIS
   Searches for the password protection of a Word file.
.DESCRIPTION
   Searches for the password protection of a Word file using a list of passwords contained in a text file.
.PARAMETER DocumentFile
   Path of the Word file
.PARAMETER PasswordsFile
   Path of the text file containing the list of passwords.
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    30/03/2024 
   Version: 1.0 
.LINK  
#>

Param(
  [Parameter(Mandatory=$True)]
  [string]$DocumentFile,
  [Parameter(Mandatory=$True)]
  [string]$PasswordsFile
)

Set-StrictMode -Version Latest

# Initializations
$word = $null
$document = $null

Try {

  #Check document file exists
  $documentFileExists = Test-Path $DocumentFile
  If ($DocumentFileExists -eq $false) {
    Write-Host "The '$DocumentFile' file not exists!" -ForegroundColor Red
    Exit 1
  }

 
  #Check document has password
  $documentHasPassword = [bool]((Get-Content $DocumentFile) -match "http://schemas.microsoft.com/office/2006/keyEncryptor/password" )
  If ($documentHasPassword -eq $false) {
    Write-Host "The '$DocumentFile' file has no password!" -ForegroundColor Red
    Exit 1
  }

  Write-Host "The '$DocumentFile' file has password!" -ForegroundColor Green

  #Check passwords file exists
  $passwordsFileExists = Test-Path $PasswordsFile
  If ($passwordsFileExists -eq $false) {
    Write-Host "The '$PasswordsFile' file not exists!" -ForegroundColor Red
    Exit 1
  }
 
  #Read passwords file
  $passwordsFileContents = Get-Content -Path $PasswordsFile

  Write-Host  "'$PasswordsFile' file contains $($passwordsFileContents.Length) passwords."  -ForegroundColor Green

  #Create Word instance
  $word = New-Object -ComObject "Word.Application"

  #Test Passwords
  $i = 1
  ForEach ($password in $passwordsFileContents) {
    Write-Progress -PercentComplete ($i*100/$passwordsFileContents.Length) -Status "Processing password $password" -Activity "Password $i of $($passwordsFileContents.Length)"

    Try {
      $document = $word.Documents.Open($DocumentFile, $false, $true, $false, $password)
      Write-Host "Password found: $password" -ForegroundColor Yellow
      Exit 0
    }
    Catch {
      $i++
    }
    Finally {
      If ($document -ne $null) {
        $document.Close()
        $document = $null
      }
    }

  }

  Write-Host "Password not found!" -ForegroundColor Yellow

}
Catch {
  Write-Host "Error: $PSItem.Exception.Message" -ForegroundColor Red
  IF($PSItem.Exception.InnerException -ne $null){Write-Host $PSItem.Exception.InnerException -ForegroundColor Red}
  Write-Host $PSItem.ScriptStackTrace -ForegroundColor Red

  Exit 1
}
Finally {
   #Close Word
   If ($word -ne $null) {$word.Quit()}
}

