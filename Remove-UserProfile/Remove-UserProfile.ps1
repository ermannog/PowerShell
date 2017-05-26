#Requires -RunAsAdministrator

<#
.SYNOPSIS
   Delete user profiles on local or remote computer, the session in which you are running the script must be started with elevated user rights (Run as Administrator).
.DESCRIPTION
   This script delete the user profiles on local o remote computer that match the search criteria.
.PARAMETER UserName
   User Name to delete user profile, is possible use the '*' wildchar.
.PARAMETER ExcludeUserName
   User name to exclude, is possible use the '*' wildchar.
.PARAMETER InactiveDays
   Inactive days of the profile, this parameter is optional and specify that the profile will be deleted only if not used for the specifed days.
.PARAMETER ComputerName
   Host name or list of host names on witch delete user profile, this parameter is optional (the default value is local computer).
.PARAMETER IncludeSpecialUsers
   Include also special system service in the search, this parameter is optional (the default value is False).
.PARAMETER Force
   Force execution without require confirm (the default value is False).
.EXAMPLE
   ./Remove-UserProfile.ps1 -UserName "LoganJ"
   Delete the profile of the user with user name equal LoganJ.
.EXAMPLE
   ./Remove-UserProfile.ps1 -UserName "Logan*"
   Delete all user profiles of the user with user name begin with "Logan".
.EXAMPLE
   ./Remove-UserProfile.ps1 -UserName "*" -InactiveDays 30
   Delete all user profiles inactive by 30 days.
.EXAMPLE
   ./Remove-UserProfile.ps1 -UserName "*" -ExcludeUserName Admistrator
   Delete all user profiles exclude user name Administrator
.EXAMPLE
   ./Remove-UserProfile.ps1 -UserName "*" -Force
   Delete all user profiles without require confim
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    05/26/2017 
   Version: 1.1 
.LINK  
#>


[cmdletbinding(ConfirmImpact = 'High', SupportsShouldProcess=$True)]
Param(
  [Parameter(Mandatory=$True)]
  [string]$UserName,
  [string]$ExcludeUserName = [string]::Empty,
  [uint32]$InactiveDays = [uint32]::MaxValue,
  [string[]]$ComputerName = $env:computername,
  [switch]$IncludeSpecialUsers = $False,
  [switch]$Force = $False
)

Set-strictmode -version latest

ForEach ($computer in $ComputerName)
{
  $profileFounds = 0

  Try {
    $profiles = Get-WmiObject -Class Win32_UserProfile -Computer $computer -Filter "Special = '$IncludeSpecialUsers'" -EnableAllPrivileges
  } Catch {            
    Write-Warning "Failed to retreive user profiles on $ComputerName"
    Exit
  }

  
  ForEach ($profile in $profiles) {
    $sid = New-Object System.Security.Principal.SecurityIdentifier($profile.SID)               
    $account = $sid.Translate([System.Security.Principal.NTAccount])
    $accountDomain = $account.value.split("\")[0]           
    $accountName = $account.value.split("\")[1]
    $profilePath = $profile.LocalPath
    $loaded = $profile.Loaded
    $lastUseTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($profile.LastUseTime)
    $special = $profile.Special

    #Calculation of the login date
    $lastLoginDate = $null
    If ($accountDomain.ToUpper() -eq $computer.ToUpper()) {$lastLoginDate = [datetime]([ADSI]"WinNT://$computer/$accountName").LastLogin[0]}

    #Calculation of the unused days of the profile
    $profileUnusedDays=0
    If (-Not $loaded){
      If($lastLoginDate -eq $null){ $profileUnusedDays = (New-TimeSpan -Start $lastUseTime -End (Get-Date)).Days }
      Else{$profileUnusedDays = (New-TimeSpan -Start $lastLoginDate -End (Get-Date)).Days} 
    }   
              
    If($accountName.ToLower() -Eq $UserName.ToLower() -Or 
      ($UserName.Contains("*") -And $accountName.ToLower() -Like $UserName.ToLower())) {
      
      If($ExcludeUserName -ne [string]::Empty -And -Not $ExcludeUserName.Contains("*") -And ($accountName.ToLower() -eq $ExcludeUserName.ToLower())){Continue}
      If($ExcludeUserName -ne [string]::Empty -And $ExcludeUserName.Contains("*") -And ($accountName.ToLower() -Like $ExcludeUserName.ToLower())){Continue}

      If($InactiveDays -ne [uint32]::MaxValue -And $profileInactiveDays -le $InactiveDays){continue}

      $profileFounds ++

      If ($profileFounds -gt 1) {Write-Host "`n"}
      Write-Host "Start deleting profile ""$account"" on computer ""$computer"" ..." -ForegroundColor Green
      Write-Host "Account SID: $sid"
      Write-Host "Special system service user: $special"
      Write-Host "Profile Path: $profilePath"
      Write-Host "Loaded : $loaded"
      Write-Host "Last use time: $lastUseTime"
      If ($lastLoginDate -ne $null) { Write-Host "Last login: $lastLoginDate" }
      Write-Host "Profile unused days: $profileUnusedDays"

      If ($loaded) {
       Write-Warning "Cannot delete profile because is in use"
       Continue
      }

      If ($Force -Or $PSCmdlet.ShouldProcess($account)) {
        Try {
          $profile.Delete()           
          Write-Host "Profile deleted successfully" -ForegroundColor Green        
        } Catch {            
          Write-Host "Error during delete the profile" -ForegroundColor Red
        }
      } 
    }
  }

  If($profileFounds -eq 0){
    Write-Warning "No profiles found on $ComputerName with Name $UserName"
  }
}