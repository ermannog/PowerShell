<#
.SYNOPSIS
   Convert a Word file to PDF.
.DESCRIPTION
   Convert a Word file to PDF, requires Microsoft Word to be installed on computer.
.PARAMETER InputFile
   Path of the Word file to convert to PDF.
.PARAMETER OutputFile
   Path of the PDF file to generate.
.PARAMETER PDFACompliant
   Switch to generate a PDF/A compliant file (Default value is False).
.PARAMETER Log
   Switch to generate a log file (Default value is False).
.EXAMPLE
   ./Convert-WordDocumentToPDF.ps1 -InputFile '".\Test.docx"' -OutputFile '".\Test.pdf"'
   ./Convert-WordDocumentToPDF.ps1 -InputFile '".\Test.docx"' -OutputFile '".\Test-A.pdf"' -PDFACompliant
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    03/26/2023 
   Version: 1.0 
.LINK
   https://github.com/ermannog/PowerShell/tree/master/Convert-WordDocumentToPDF
#>

Param(
  [Parameter(Mandatory=$True)]
  [String]$InputFile,
  [Parameter(Mandatory=$True)]
  [String]$OutputFile,
  [Switch]$PDFACompliant=$False,
  [Switch]$Log=$False
)

Set-strictmode -version latest

# Variabiles
$Message = ""
$Word = $null
$Document = $null

# Set Log File name
$LogFileName = [System.IO.Path]::GetFileNameWithoutExtension((Split-Path $PSCommandPath -Leaf)) + ".log"
$LogFilePath = Join-Path -Path (Split-Path $PSCommandPath -Parent) -ChildPath $LogFileName
If ($Log) {Write-Host "Log enabled on file $LogFilePath"  -ForegroundColor Blue}

$Message = "Starting file conversion $InputFile to $OutputFile."
Write-Host $Message  -ForegroundColor Green
If ($Log) {(Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $LogFilePath}

Try {
    # Load Microsoft Word
    $Message = "Loading Microsoft Word ..."
    Write-Host $Message  -ForegroundColor Yellow
    If ($Log) {(Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $LogFilePath -Append}

    $Word = New-Object -ComObject Word.Application

    # Open input file
    $Message = "Opening file $InputFile ..."
    Write-Host $Message  -ForegroundColor Yellow
    If ($Log) {(Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $LogFilePath -Append}

    $Document = $Word.Documents.Open($InputFile, $False, $True)

    # Convert input file
    $Message = "Start converting to PDF on file $OutputFile ..."
    Write-Host $Message  -ForegroundColor Yellow
    If ($Log) {(Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $LogFilePath -Append}

    If ($PDFACompliant -eq $False) {
        $Document.SaveAs2($OutputFile, [Microsoft.Office.Interop.Word.WdExportFormat]::wdExportFormatPDF)
    }
    Else {
        $Document.ExportAsFixedFormat($OutputFile, [Microsoft.Office.Interop.Word.WdExportFormat]::wdExportFormatPDF, `
                                 $False, [Microsoft.Office.Interop.Word.WdExportOptimizeFor]::wdExportOptimizeForPrint, `
                                 [Microsoft.Office.Interop.Word.WdExportRange]::wdExportAllDocument, 0, 0,  `
                                 [Microsoft.Office.Interop.Word.WdExportItem]::wdExportDocumentContent, `
                                 $True, $True, [Microsoft.Office.Interop.Word.WdExportCreateBookmarks]::wdExportCreateNoBookmarks, `
                                 $True, $True, $True)
    }

    $Message = "The $OutputFile file has been generated."
    Write-Host $Message  -ForegroundColor Green
    If ($Log) {(Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $LogFilePath -Append}
}
Catch{
    Write-Host $_ -ForegroundColor Red
    If ($Log) {$_ | Out-File $LogFilePath -Append}
}

#Close Document
Try{
    If ($Document -ne $null) {
        $Message = "Closing file $InputFile" 
        Write-Host $Message  -ForegroundColor Yellow
        If ($Log) {(Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $LogFilePath -Append}

        $Document.Close([Microsoft.Office.Interop.Word.WdSaveOptions]::wdDoNotSaveChanges)
        [System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($Document) | Out-Null
        $Document= $null
    }
}
Catch{
    Write-Host $_ -ForegroundColor Red
    If ($Log) {$_ | Out-File $LogFilePath -Append}
}

#Close Word
Try{
    If ($Word -ne $null) {
        $Message = "Closing Microsoft Word" 
        Write-Host $Message  -ForegroundColor Yellow
        If ($Log) {(Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $LogFilePath -Append}

        $Word.Quit()
        [System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($Word) | Out-Null
        $Word = $null
    }
}
Catch{
    Write-Host $_ -ForegroundColor Red
    If ($Log) {$_ | Out-File $LogFilePath -Append}
}

#Release resources
Try{
    $Message = "Release resources..."
    Write-Host $Message  -ForegroundColor Yellow
    If ($Log) {(Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $LogFilePath -Append}

    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
Catch{
    Write-Host $_ -ForegroundColor Red
    If ($Log) {$_ | Out-File $LogFilePath -Append}
}
