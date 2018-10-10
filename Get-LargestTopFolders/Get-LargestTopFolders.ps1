<#
.SYNOPSIS
   Searches for larger folders in a specified path.
.DESCRIPTION
   This script searches for larger folders in a specified path, returning the size, the number of files contained, and the number of subfolders
.PARAMETER Path
   Specifies the path in which the folders will be examined. This parameter is required.
.PARAMETER TopFolders
   Specifies the number of folders with a larger size that will be returned. This parameter is optional, the default value is 10.
.EXAMPLE
   ./Get-LargestTopFolders -Path "E:" -TopFolders 5
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    10/10/2018 
   Version: 1.0 
.LINK  
#>

Param(
  [Parameter(Mandatory=$True)]
  [string]$Path,
  [uint32]$TopFolders = 10
)

Set-StrictMode -Version Latest


$Folders = Get-ChildItem -Path $Path -Directory -Recurse

$FoldersInfo = $Folders | Select-Object FullName, @{Name='Size'; Expression={((Get-ChildItem -Path $_.FullName -File -Recurse | Measure-Object Length -Sum).Sum)}}, @{Name='Files'; Expression={((Get-ChildItem -Path $_.FullName -File -Recurse | Measure-Object Length -Sum).Count)}}, @{Name='Subfolders'; Expression={(Get-ChildItem -Path $_.FullName -Directory -Recurse | Measure-Object).Count}}

$FoldersInfoSorted = $FoldersInfo | Sort-Object Size -Descending

$TopFoldersInfoSortedFormatted = $FoldersInfoSorted | Select-Object @{Name='Folder'; Expression={($_.FullName).Substring($Path.Length+1)}}, @{Name='Size [GB]'; Expression={[Math]::Round($_.Size / 1GB, 2).ToString('#,##0.##').PadLeft(8)}}, Files, Subfolders -First $TopFolders

# Output data
$Host.UI.RawUI.ForegroundColor = "Green"
Write-Output $TopFoldersInfoSortedFormatted