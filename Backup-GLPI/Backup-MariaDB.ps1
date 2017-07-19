Param( 
 [string]$MariaBackupFile, 
 [string]$BackupRoot,
 [string]$MariaDBHost,
 [string]$User,
 [string]$Password,
 [uint32]$BackupsRetained
)

Set-strictmode -version latest

# Impostazioni di Test
#$MariaBackupFile= $env:ProgramFiles + "\MariaDB 10.2\bin\mariabackup.exe"
#$BackupRoot="Z:\Backup-MariaDB"
#$MariaDBHost="."
#$User="root"
#$Password="P@assW0rd!"
#$BackupsRetained = 10

# Inizializzazione Backup
$BackupPath=$BackupRoot + "\" + (Get-Date -format yyyy-MM-dd)
If (Test-Path $BackupPath) {Remove-Item $BackupPath -Force -Recurse}
New-Item -ItemType Directory -Force -Path $BackupPath

# Avvio backup MariaDB
$TargetArg = "--target-dir=" + $BackupPath
$MariaDBHostArg = "--host=" + $MariaDBHost
$UserArg = "--user=" + $User
$PasswordArg = "--password=" + $password

# Invoke-Expression $BackupMariaDBCommand
Start-Process -NoNewWindow -Wait -FilePath $MariaBackupFile -ArgumentList "--backup", $TargetArg, $MariaDBHostArg, $UserArg, $PasswordArg

# Eliminazione backup obsoleti
$BackupDirectories = (Get-ChildItem -Directory $BackupRoot | Sort FullName)
$BackupsCount = ($BackupDirectories | Measure-Object).Count

If ($BackupsCount -gt $BackupsRetained){
  For ($i = 1; $i -le $BackupsCount – $BackupsRetained; $i++) {
    Remove-Item $BackupDirectories[$i-1].FullName -Force -Recurse
  }
}
