# Description
DGet a Report in CSV format of file information in the specified path.

**Version: 1.0 - Date: 08/24/2018**
# Parameters
**Path**

Path of where retrive file information.

**OutputCSVFile**

Path of CSV Report.

**Recurse**

Allows Get files in all subdirectories.

**Recurse**

Allows to get files that cannot otherwise not be accessed by the user such as hidden or system files, even when using the -Force parameter the cmdlet cannot override security restrictions (the default value is False).

# Examples
**EXAMPLE 1:** *Get CSV report of file info in the temp path of current user and save it in the file C:\Reports\TempDirFileInfo.csv

./Get-CSVReportFileInfo.ps1  -Path "%tempJ" -OutputCSVFile "C:\Reports\TempDirFileInfo.csv"

