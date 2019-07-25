# Description
Delete user profiles on local or remote computer that match the search criteria, the session in which you are running the script must be started with elevated user rights (Run as Administrator).

**Version: 1.2 - Date: 07/25/2019**
# Parameters
**UserName**

User Name to delete user profile, is possible use the '*' wildchar.

**ExcludeUserName**

User name to exclude, is possible use the '*' wildchar.

**InactiveDays**

Inactive days of the profile, this parameter is optional and specify that the profile will be deleted only if not used for the specifed days.

**ComputerName**

Host name or list of host names on witch delete user profile, this parameter is optional (the default value is local computer).

**IncludeSpecialUsers**

Include also special system service in the search, this parameter is optional (the default value is False).

**Force**

Force execution without require confirm (the default value is False).

# Examples
**EXAMPLE 1:** *Delete the profile of the user with user name equal LoganJ*

./Remove-UserProfile.ps1  -UserName "LoganJ"

**EXAMPLE 2:** *Delete all user profiles of the user with user name begin with "Logan"*

./Remove-UserProfile.ps1  -UserName "Logan*"

**EXAMPLE 3:** *Delete all user profiles inactive by 30 days.*

./Remove-UserProfile.ps1  -UserName "*" -InactiveDays 30

**.EXAMPLE 4:** *Delete all user profiles exclude user name Administrator*

./Remove-UserProfile.ps1  -UserName "*" -ExcludeUserName Admistrator

**.EXAMPLE 5:** *Delete all user profiles without require confim*
./Remove-UserProfile.ps1  -UserName "*" -Force
