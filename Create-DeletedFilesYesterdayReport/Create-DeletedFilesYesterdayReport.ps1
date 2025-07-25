Set-strictmode -version latest

# Impostazioni Costanti
$ReportFilesRetained = 180
$ReportFileNamePrefix = "DeletedFiles-"

# Impostazioni Variabili
$Yesterday = (Get-Date).AddDays(-1).Date
$Today = $yesterday.AddDays(1)

$LogFileName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path) + ".log"
$PathFileLog = Join-Path ($PSScriptRoot) ($LogFileName)

$ReportFileName = "$ReportFileNamePrefix$($yesterday.ToString('yyyy-MM-dd')).csv"
$ReportFilePath = Join-Path ($PSScriptRoot) ("DeletedFilesReports")
$PathFileReport = Join-Path ($ReportFilePath) ($ReportFileName)
$Message = ""

Try {
  $Message = "Ricerca eventi di sicurezza 4663 del $Yesterday"
  Write-Host $Message -ForegroundColor Blue
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog

  $events = Get-WinEvent -FilterHashTable @{Logname=’Security’;ID=4663;StartTime=$Yesterday;EndTime=$Today} | Where {$_.Properties[9].Value -eq 65536}
  $events = $events | Select-Object -Property TimeCreated, @{Label='Account'; Expression={$_.Properties[1].Value}}, @{Label='Object'; Expression={$_.Properties[6].Value}}

  # Esporta i risultati in CSV
  If ($events.Count -gt 0) {
    # Creazione cartella report
    If (!(Test-Path $ReportFilePath)) {
      New-Item $ReportFilePath -type directory
    }

    # Esportazione su file csv
    $events | Export-Csv -Path $PathFileReport -NoTypeInformation -Encoding UTF8
    
    $Message = "Log creato: $PathFileLog"
    Write-Host $Message -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append


    # Eliminazione log file obsoleti
    $reportFileNameBase = Join-Path ($ReportFilePath) ($ReportFileNamePrefix)
    $reportFiles = Get-ChildItem $ReportFilePath –PipelineVariable item | Where {$item.psIsContainer -eq $false -and $item.FullName -like ($reportFileNameBase + "*")} | Sort FullName
    $reportFilesCount = ($reportFiles | Measure-Object).Count

    If ($reportFilesCount -gt $ReportFilesRetained){
      $Message = "Remove old report files..."
      Write-Host $Message -ForegroundColor Blue
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append
      
      For ($i = 1; $i -le $reportFilesCount - $ReportFilesRetained; $i++) {
        write-host $reportFiles[$i-1].FullName

        $Message = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " Eliminazione report file " + $reportFiles[$i-1].FullName
        Write-Host $Message -ForegroundColor Blue
        (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append

        Remove-Item $reportFiles[$i-1].FullName
      }
  }

  } Else {
    $Message = "Nessun file eliminato rilevato per il $($yesterday.ToString('yyyy-MM-dd'))."
    Write-Host $Message -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append
  }
}
Catch{
    $Message = "Errore: $_"
    Write-Host $Message -ForegroundColor Red
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -append
}