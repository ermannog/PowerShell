# Description
Create a report of non-responsive cameras in a Milestone software-based VMS based on what is logged on the XProtect Event Server.
The connection to the Management Server is made with the credentials with which the script was started.
This script requires MilestonePSTools Module version 25.2.61 or later (https://milestonepstools.com/)

**Version: 1.1 - Date: 07/20/2026**
# Parameters
**PathDataFileMilestonePSTools**

Specifies the path of data file(.psd1) of MilestonePSTools Module.
If not specified the MilestonePSTools Module must be installed on the system.

**ServerAddress**

Specifies the Management Server address using either an http or https scheme.
For example, "http://managementserver".

**PathFileReport**

Specifies the path of report file.
By default, a report file named 'CameraNotRespondingReport.html' is created in the same directory where the script is run.
The html report file uses, if it exists, a css file named the same as the report file with the extension css
(by default CameraNotRespondingReport.css) stored in the same directory as the html report file.

# Examples
**EXAMPLE 1:**  *Create a report of non-responsive cameras specify the path of MilestonePSTools.*

./Get-CameraNotRespondingReport.ps1 -PathDataFileMilestonePSTools C:\MilestonePSTools\milestonepstools.25.2.61\MilestonePSTools.psd1 -ServerAddress "https://vms.contoso.com"
