<#
.SYNOPSIS
   Set desktop wallpaper.
.DESCRIPTION
   This script desktop wallpaper if the current users using SystemParametersInfo function in the User32.dll.
.PARAMETER FilePath
   Path of the wallpaper file.
.EXAMPLE
   ./Set-Wallpaper.ps1 "C:\Images\Wallpaper.png"
   Set desktop wallpaper to the file C:\Images\Wallpaper.png.
.NOTES
   Author:  Ermanno Goletto
   Blog:    www.devadmin.it
   Date:    06/04/2018 
   Version: 1.0 
.LINK
   https://github.com/ermannog/PowerShell/tree/master/Set-Wallpaper
#>

Param(
  [Parameter(Mandatory=$True)]
  [String]$FilePath,
  [ValidateSet('Center','Fill','Fit', 'Streatch', 'Tile')]
  [String]
  $Location = 'Center'
)


# Define a class PInvoke in the namespace Win32Functions with a method SystemParametersInfo for call the function SystemParametersInfo in the User32.dll
Set-Variable MemberDefinition -Option Constant -Value @"
<System.Runtime.InteropServices.DllImport("User32.dll")> 
Public Shared Function SystemParametersInfo(ByVal uiAction As System.UInt32, 
                                            ByVal uiParam As System.UInt32, 
                                            ByVal pvParam As System.String, 
                                            ByVal fWinIni As System.UInt32) As System.Int32
  ' Returns non-zero value if function succeeds
End Function
"@

Add-Type -MemberDefinition $MemberDefinition -Name "PInvoke" -Namespace Win32Functions -Language VisualBasic

# Set WallPaper using SystemParametersInfo function in the User32.dll
Set-Variable SPI_SETDESKWALLPAPER -Option Constant -Value 0x0014
Set-Variable SPIF_UPDATEINIFILE -Option Constant -Value 0x01
Set-Variable SPIF_SENDCHANGE -Option Constant -Value 0x02

[Win32Functions.PInvoke]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $FilePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)


# Set Wallpaper location
Switch ( $Location )
  {
    Center
      {
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name WallpaperStyle -Value 0
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name TileWallpaper -Value 0
      }
    Tile
     {
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name WallpaperStyle -Value 0
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name TileWallpaper -Value 1
     }
    Streatch
     {
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name WallpaperStyle -Value 2
     }
    Fit
      {
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name WallpaperStyle -Value 6
      }
    Fill
      {
        Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name WallpaperStyle -Value 10
    }
  }