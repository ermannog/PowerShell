<#
.SYNOPSIS
   Get CSV Report of file.
.DESCRIPTION
   Get a Report in CSV format of file information in the specified path.
.PARAMETER Path
   Path of where retrive file information.
.PARAMETER OutputCSVFile
   Path of CSV Report.
.PARAMETER Recurse
   Allows to get files in all subdirectories (the default value is False).
.PARAMETER Force
   Allows to get files that cannot otherwise not be accessed by the user such as hidden or system files, even when using the -Force parameter the cmdlet cannot override security restrictions (the default value is False).
.EXAMPLE
   ./Get-CSVReportFileInfo.ps1 "%Temp%" "C:\Reports\TempDirFileInfo.csv"
   Get a Report in CSV format of file information in the temp path of the current user and save it in the file C:\Reports\TempDirFileInfo.csv.

   ./Get-CSVReportFileInfo.ps1 "%Temp%" "C:\Reports\TempDirFileInfo.csv" -Recurse:$False -Force:$False
   Get a Report in CSV format of file information in the temp path of the current user without use recursion and without search for hidden or system files and save it in the file C:\Reports\TempDirFileInfo.csv.
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    24/08/2018 
   Version: 1.0 
.LINK
   https://github.com/ermannog/PowerShell/tree/master/Get-CSVReportFileInfo
#>

Param(
  [Parameter(Mandatory=$True)]
  [String]$Path,
  [Parameter(Mandatory=$True)]
  [String]$OutputCSVFile,
  [Switch]$Recurse = $True,
  [Switch]$Force = $True
)

Set-strictmode -version latest

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

# Search files in the path
If ($Recurse -And $Force){
  $Files = Get-ChildItem $Path -File -Recurse -Force
}
ElseIf ($Recurse){
  $Files = Get-ChildItem $Path -File -Recurse -Force
}
ElseIf ($Force){
  $Files = Get-ChildItem $Path -File -Recurse -Force
}
Else {
  $Files = Get-ChildItem $Path -File
}


# Get Files Info
$FilesInfo = $Files | Select-Object DirectoryName, Name, LastWriteTime, @{Name="Size";Expression={Get-FriendlySize $_.Length}}, @{Name="Owner";Expression={(Get-Acl $_.FullName).Owner}}, @{Name="Bytes"; Expression={$_.Length}}

# Create report CSV
$FilesInfo | Export-CSV -NoTypeInformation $OutputCSVFile