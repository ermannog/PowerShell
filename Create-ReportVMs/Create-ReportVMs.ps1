<#
.SYNOPSIS
   Create a report of VMs running on Hyper-V Host.
.DESCRIPTION
   This script create a report of VMs running on Hyper-V Host.
.PARAMETER OutputFile
   Path of Report file.
.EXAMPLE
   ./Create-ReportVMs.ps1 -OutputFile '"%PUBLIC%\Desktop\Report VMs.txt"'
   Create a report of the VMs on all users desktop named "Report VMs.txt"
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    03/17/2023 
   Version: 1.0 
.LINK
   https://github.com/ermannog/PowerShell/tree/master/Create-ReportVMs
#>

Param(
  [Parameter(Mandatory=$True)]
  [String]$OutputFile
)

Set-strictmode -version latest



Try {
 #Clear Report File
 If (Test-Path $OutputFile) { Clear-Content $OutputFile }

 # Read Host Memory
 $HostPhysicalMemoryDevices = (Get-WmiObject -Class Win32_PhysicalMemory).Capacity | Measure-Object -Sum
 $HostMemory = [math]::Round((($HostPhysicalMemoryDevices).Sum)/1GB)
 $HostMemorySlots = ($HostPhysicalMemoryDevices).Count
 Write-Host "Host Memory: $HostMemory GB" -ForegroundColor Green

 # Read Host CPU
 $HostProcessors = Get-WmiObject -Class Win32_Processor -Property NumberOfCores, NumberOfLogicalProcessors | Select NumberOfCores, NumberOfLogicalProcessors
 $HostCPUSockets = ($HostProcessors | Measure-Object).Count
 $HostCPUCores = ($HostProcessors | Measure-Object -Property NumberOfCores -Sum).Sum
 $HostCPULogicalProcessors = ($HostProcessors | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
 Write-Host "Host CPU: $HostCPUSockets Sockets" -ForegroundColor Green

 # Read VM with Automatic Startup
 $VMs = Get-VM | Where-Object AutomaticStartAction -ne Nothing
 $VMsTotalMemory = ($VMs | Measure-Object -Property MemoryStartup -Sum).Sum/1GB
 $VMsTotalvCPU = ($VMs | Measure-Object -Property ProcessorCount -Sum).Sum
 $VMsTable = $VMs |Sort-Object AutomaticStartDelay
 $VMsTable = $VMsTable | Format-Table -AutoSize -Wrap `
                                      @{Name="Name"; Expression={$_.VMName}}, `
                                      @{Name="vCPU"; Expression={$_.ProcessorCount}}, `
                                      @{Name="RAM"; Expression={($_.MemoryStartup/1GB).ToString() + " GB"}; Align="Right"}, `
                                      @{Name="State"; Expression={$_.State}; Align="Center"}, `
                                      @{Name="Start Delay"; Expression={($_.AutomaticStartDelay).ToString() + " Sec"}; Align="Right"}, `
                                      @{Name="Stop Action"; Expression={$_.AutomaticStopAction}; Align="Center"}, `
                                      Notes,  `
                                      @{Name="Dynamic Memory"; Expression={$_.DynamicMemoryEnabled}; Align="Center"}, `
                                      Generation, `
                                      @{Name="Version"; Expression={$_.Version}; Align="Right"}
  $VMsTable = $VMsTable | Out-String -Width 256


  Write-Host "`r`n`r`nVMs with Automatic Startup:" -ForegroundColor Blue
  Write-Host $VMsTable -ForegroundColor Blue

  # Create Report - Section Memory
  $ReportSectionMemory = "Host Memory:`t$HostMemory GB ($HostMemorySlots Slots)".PadRight(70)
  $ReportSectionMemory += "VMs Total Memory:`t$VMsTotalMemory GB"
  $ReportSectionMemory | Out-File $OutputFile -Append

  # Create Report - Section CPUs
  $ReportSectionCPUs = "Host CPU:`t$HostCPULogicalProcessors Logical Processors ($HostCPUSockets Sockets - $HostCPUCores Cores)".PadRight(67)
  $ReportSectionCPUs += "VMs Total vCPU:`t$VMsTotalvCPU"
  $ReportSectionCPUs | Out-File $OutputFile -Append

  # Create Report - Section VMs
  "`r`n`r`n`r`nVMs with Automatic Startup:" | Out-File $OutputFile -Append
  $VMsTable | Out-File $OutputFile -Append

  # Create Report - Section Date
  "File created on: " + (Get-Date -Format f) | Out-File $OutputFile -Append

}
Catch{
  Write-Host $_ -ForegroundColor Red
  $_ | Out-File $OutputFile -append
}
