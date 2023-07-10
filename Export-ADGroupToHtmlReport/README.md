# Description
Export AD User in Html, the script must be run under the credentials of a domain user.

**Version: 1.2 - Date: 06/07/2023**

# Parameters

**GroupId**

Active Directory group name.

**Notes**

Annotations.

**PathDirectoryReports**

Path where the report will be created. By default the report is created in the Reports subfolder.

**PathFileCSSSource**

Path of the source CSS file used by the report, the file will be copied to the report folder. By default, the Style.css file in the script folder will be copied into the folder where the report is generated. is generated.

**OpenReport**

Opens the report after generating it By default is False.

# Examples

**EXAMPLE 1:**  *Created report of Active Directory group named 'SalesUsers' and opened report after creation.*

./Export-ADGroupToHtmlReport.ps1 -GroupId SalesUsers -OpenReport
