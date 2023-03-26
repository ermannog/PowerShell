# Description
Create a report of VMs running on Hyper-V Host.

The script can be run on Windows Server 2012 R2 and later.

The VMs that are taken into consideration are those that are set "potentially" to start automatically, i.e. VMs that start automatically or that start because they were running when the Hyper-V host was shut down.

**Version: 1.0 - Date: 03/17/2023**

# Parameters

**OutputFile**

Path of Report file.

# Examples

**EXAMPLE 1:**  *Create a report of the VMs on all users desktop named "Report VMs.txt"*

./Create-ReportVMs.ps1 -OutputFile '"%PUBLIC%\Desktop\Report VMs.txt"'
