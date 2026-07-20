<#
.SYNOPSIS

Create a report of non-responsive cameras in a Milestone software-based VMS.

.DESCRIPTION

Create a report of non-responsive cameras in a Milestone software-based VMS based on what is logged on the XProtect Event Server.
The connection to the Management Server is made with the credentials with which the script was started.

.PARAMETER PathDataFileMilestonePSTools
Specifies the path of data file(.psd1) of MilestonePSTools Module.
If not specified the MilestonePSTools Module must be installed on the system.

.PARAMETER ServerAddress
Specifies the Management Server address using either an http or https scheme.
For example, "http://managementserver".

.PARAMETER PathFileReport
Specifies the path of report file.
By default, a report file named 'CameraNotRespondingReport.html' is created in the same directory where the script is run.
The html report file uses, if it exists, a css file named the same as the report file with the extension css
(by default CameraNotRespondingReport.css) stored in the same directory as the html report file.

.NOTES
Author:  Ermanno Goletto
Blog:    www.devadmin.it
Date:    07/20/2026 
Version: 1.1 

.LINK
   https://github.com/ermannog/PowerShell/tree/master/Get-CameraNotRespondingReport

.COMPONENT
This script requires MilestonePSTools Module version 25.2.61 or later (https://milestonepstools.com/)
#>

Param(
  [String]$PathDataFileMilestonePSTools = "",
  [Parameter(Mandatory=$True)]
  [String]$ServerAddress,
  [String]$PathFileReport = "$PSScriptRoot\CameraNotRespondingReport.html"
)

Set-StrictMode -Version Latest

# Impostazioni Variabili
$PathFileLog = Join-Path ($PSScriptRoot) ([System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath) + ".log")
$ReportTitle = "Check Cameras not responding on $(Get-Date -Format 'dd-MM-yyyy HH:mm:ss')"
$ReportStyleSheetFileName = [System.IO.Path]::GetFileNameWithoutExtension($PathFileReport) + ".css"
$Message = ""

Try {
  # Create log file
  $Message = "Create log file $PathFileLog."
  Write-Host $Message  -ForegroundColor Green
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog
  

  # Import Module MilestonePSTools Module
  If ($PathDataFileMilestonePSTools -ne ""){
    $Message = "Import Module MilestonePSTools Module."
    Write-Host $Message  -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

    Import-Module $PathDataFileMilestonePSTools
  } Else {
    Import-Module MilestonePSTools
  }
  

  # Connect to VMS Server
  $Message = "Connect to VMS Server."
  Write-Host $Message  -ForegroundColor Green
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

  Connect-VMS -ServerAddress $ServerAddress -ErrorAction Stop

  # Camera and hardware counting
  $Message = "Camera and hardware counting."
  Write-Host $Message  -ForegroundColor Green
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

  $cameraTotal = ((Get-VmsCamera).Count).ToString("#,##0")
  $hardwareTotal = ((Get-VmsHardware).Count).ToString("#,##0")

  # Search for unresponsive cameras based on what is logged on the XProtect Event Server
  $Message = "Search for unresponsive cameras."
  Write-Host $Message  -ForegroundColor Green
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

  # Initialize results list
  $results = New-Object System.Collections.ArrayList

  $itemsNotResponding = (Get-ItemState -CamerasOnly | Where-Object State -ne 'Responding')

  If ($itemsNotResponding -ne $null){
 
    # Analysis of unresponsive Cameras
    $Message = "Analysis of unresponsive Cameras."
    Write-Host $Message  -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

    Foreach ($item in $itemsNotResponding){
      $Message = "Item Id: " + $item.Id
      Write-Host $Message  -ForegroundColor Green
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

      # Get camera record from the Milestone XProtect Management Server
      $camera = Get-VmsCamera -Id $item.FQID.ObjectId

      $Message = "Camera: " + $camera.DisplayName
      Write-Host $Message  -ForegroundColor Green
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

      # Get hardware device from the camera
      $hardware = Get-VmsHardware -Id $camera.ParentItemPath.Replace("Hardware[", "").Replace("]", "")
      
      $Message = "Hardware Enabled: " + $hardware.Enabled
      Write-Host $Message  -ForegroundColor Green
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

      $Message = "Hardware Model: " + $hardware.Model
      Write-Host $Message  -ForegroundColor Green
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

      # Excluding cameras with hardware disabled
      If ($hardware.Enabled -eq $False) { Continue }

      # Gets recording server from the hardware
      $recordingServer = Get-VmsRecordingServer -Id $hardware.ParentItemPath.Replace("RecordingServer[", "").Replace("]", "")

      $Message = "Recorder: " + $recordingServer.DisplayName
      Write-Host $Message  -ForegroundColor Green
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append


      #Gets device record from the Milestone XProtect Management Server
      $device = $hardware | Get-VmsDevice

      $Message = "Device Id: " + $device.Id
      Write-Host $Message  -ForegroundColor Green
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append
        
      # Search for the date of the last recorded image
      $playbackInfo = $device | Get-PlaybackInfo -ErrorAction Ignore -WarningAction SilentlyContinue
      $lastRecordingDate = "Unknown"
      If ($playbackInfo -ne $null) {
        If ($playbackInfo.End -ne $null) { 
          $lastRecordingDate = ($playbackInfo | Sort-Object -Property End -Descending | Select-Object -Last 1).End.ToString("yyyy-MM-dd HH:mm:ss")
        }
      }

      # Get settings hardware 
      $hardwareSetting = $hardware | Get-HardwareSetting

      $Message = "Hardware Settings Product ID: " + $hardwareSetting.ProductID
      Write-Host $Message  -ForegroundColor Green
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

      $Message = "Hardware Settings Serial Number: " + $hardwareSetting.SerialNumber
      Write-Host $Message  -ForegroundColor Green
      (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

      #Add Camera to results list
      $row = [PSCustomObject]@{
        Name = $camera.DisplayName
        Address = $hardware.Address
        Recorder = $recordingServer.Name.Split('.')[0]
        Hardware = $hardware.Name
        Serial = $hardwareSetting.SerialNumber
        MAC = $hardwareSetting.MacAddress
        Firmware = $hardwareSetting.FirmwareVersion
        LastImage = $lastRecordingDate
      }
           
      $results.Add($row)

    }

    # Count of unresponsive cameras and hardware
    $Message = "Count of unresponsive cameras and hardware."
    Write-Host $Message  -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

    $cameraNotRespondingTotal = ($results.Count).ToString("#,##0")
    $hardwareNotRespondingTotal=((($results | Select Hardware -Unique) | Measure-Object).Count).ToString("#,##0")

    # Initialize report sorted list
    $reportList = $results | Select-Object *, @{Name='Last image date'; Expression = { $_.LastImage }}
    $reportList = $reportList | Select-Object -Property * -ExcludeProperty LastImage | Sort-Object -Property Name

    # HTML report creation
    $Message = "HTML report creation."
    Write-Host $Message  -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

    $reportPreContent = "<h1 align=""right"">Date: $(Get-Date -Format 'dd-MM-yyyy HH:mm:ss')</h1>"

    If ($results.Count -gt 0){
      $reportPreContent += "<h2><span style=""color: red;"">$cameraNotRespondingTotal</span> Cameras (of $cameraTotal)"
      $reportPreContent += " and <span style=""color: red;"">$hardwareNotRespondingTotal</span> Hardware (of $hardwareTotal) not responding</h2>"
    } Else {
      $reportPreContent += "<h2>All cameras are responding</h2>"
    }

    $report = $reportList | ConvertTo-Html -Title $ReportTitle -CssUri $ReportStyleSheetFileName -PreContent $reportPreContent
    
    # Report file creation
    $report | Out-File $PathFileReport -Encoding utf8

  } Else {
    # No unresponsive cameras found
    $Message = "No unresponsive cameras found."
    Write-Host $Message  -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append
  }
    
 
 } Catch {

  $Message = "Errore: $($_.Exception.Message)`nRiga: $($_.InvocationInfo.ScriptLineNumber)`nComando: $($_.InvocationInfo.Line)"
  Write-Host $Message -ForegroundColor Red
  (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

} Finally {

  If (Test-VmsConnection) {
    # Disconnessione
    $Message = "Disconnessione"
    Write-Host $Message  -ForegroundColor Green
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " " + $Message | Out-File $PathFileLog -Append

    Disconnect-Vms
  }

}