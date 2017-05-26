# Version 1.1 (05/26/2017)
# SYNOPSIS
Delete user profiles on local or remote computer, the session in which you are running the script must be started with elevated user rights (Run as Administrator).
# DESCRIPTION
This script delete the user profiles on local o remote computer that match the search criteria.
## PARAMETER UserName
User Name to delete user profile, is possible use the '*' wildchar.
## PARAMETER ExcludeUserName
User name to exclude, is possible use the '*' wildchar.
## PARAMETER InactiveDays
Inactive days of the profile, this parameter is optional and specify that the profile will be deleted only if not used for the specifed days.
## PARAMETER ComputerName
Host name or list of host names on witch delete user profile, this parameter is optional (the default value is local computer).
## PARAMETER IncludeSpecialUsers
Include also special system service in the search, this parameter is optional (the default value is False).
## PARAMETER Force
Force execution without require confirm (the default value is False).
## EXAMPLE
./Remove-UserProfile.ps1 LoganJ
*Delete the profile of the user with user name equal LoganJ.*
###.EXAMPLE
./Remove-UserProfile.ps1 Logan*
*Delete all user profiles of the user with user name begin with "Logan".*
### EXAMPLE
./Remove-UserProfile.ps1 * -InactiveDays 30
*Delete all user profiles inactive by 30 days.*
### .EXAMPLE
./Remove-UserProfile.ps1 * -ExcludeUserName Admistrator
*Delete all user profiles exclude user name Administrator*
