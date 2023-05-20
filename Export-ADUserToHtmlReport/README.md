# Description
Export AD User in Html, the script must be run under the credentials of a domain user.

**Version: 1.3 - Date: 05/20/2023**

# Parameters

**UserId**

Active Directory username.

**Notes**

Annotations.

**PathDirectoryReports**

Path where the report will be created.
By default the report is created in the Reports subfolder.

**PathFileCSSSource**

Path of the source CSS file used by the report, the file will be copied to the report folder.
By default, the Style.css file in the script folder will be copied into the folder where the report is generated. is generated.

# Examples

**EXAMPLE 1:**  *Created report of Active Directory user named 'RossiM' and opened report after creation.*

./Export-ADUserToHtmlReport.ps1 -UserID RossiM -OpenReport
