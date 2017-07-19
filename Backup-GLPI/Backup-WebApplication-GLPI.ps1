Param( 
 [string]$BackupRoot,
 [string]$WebApplicationPath,
 [string]$WebSiteName,
 [uint32]$BackupsRetained
)

Set-strictmode -version latest

# Impostazioni di Test
#$BackupRoot="Z:\Backup-WebApplication-GLPI"
#$GLPIWebApplicationPath="C:\inetpub\wwwroot\glpi"
#$WebSiteName="Default Web Site"
#$BackupsRetained = 10

# Inizializzazione Backup
$BackupPath=$BackupRoot + "\" + (Get-Date -format yyyy-MM-dd)
If (Test-Path $BackupPath) {Remove-Item $BackupPath -Force -Recurse}
New-Item -ItemType Directory -Force -Path $BackupPath

# Arresto Web Site
Stop-WebSite $WebSiteName

# Avvio Backup Web Application GLPI
Copy-Item -Path $WebApplicationPath -Destination $BackupPath –Recurse

# Avvio Web Site
Start-WebSite $WebSiteName

# Eliminazione backup obsoleti
$BackupDirectories = (Get-ChildItem -Directory $BackupRoot | Sort FullName)
$BackupsCount = ($BackupDirectories | Measure-Object).Count

If ($BackupsCount -gt $BackupsRetained){
  For ($i = 1; $i -le $BackupsCount – $BackupsRetained; $i++) {
    Remove-Item $BackupDirectories[$i-1].FullName -Force -Recurse
  }
}
