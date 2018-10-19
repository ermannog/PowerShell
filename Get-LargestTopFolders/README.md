# Description
Searches for larger folders in a specified path.

**Version: 1.0 - Date: 10/10/2018**

# Parameters

**Path**

Specifies the path in which the folders will be examined. This parameter is required.

**TopFolders**

Specifies the number of folders with a larger size that will be returned. This parameter is optional, the default value is 10.

# Examples

   ./Get-LargestTopFolders -Path "E:" -TopFolders 5
