REM *** Impostazioni di configurazione Generale ***
SET MariaBackupFile=%ProgramFiles%\MariaDB 10.2\bin\mariabackup.exe
SET MariaDBHost=.
SET User=root
SET Password=P@assW0rd!

REM *** Impostazioni di configurazione Backup MariaDB ***
SET MariaDBBackupRoot=Z:\Backup-MariaDB
SET MariaDBBackupsRetained=30

REM *** Impostazioni di configurazione Backup Database GLPI ***
SET GLPIDatabaseBackupRoot=Z:\Backup-DB-GLPI
SET GLPIDatabaseName=glpi
SET GLPIDatabaseBackupsRetained=30

REM *** Impostazioni di configurazione Backup Web Application GLPI ***
SET GLPIWebApplicationBackupRoot=Z:\Backup-WebApplication-GLPI
SET GLPIWebApplicationPath=C:\inetpub\wwwroot\glpi
SET GLPIWebApplicationBackupsRetained=30

REM *** Backup MariaDB ***
powershell -ExecutionPolicy RemoteSigned -File %~dp0\Backup-MariaDB.ps1 "%MariaBackupFile%" %MariaDBBackupRoot% %MariaDBHost% %User% %Password% %MariaDBBackupsRetained%

REM *** Backup Database GLPI ***
powershell -ExecutionPolicy RemoteSigned -File %~dp0\Backup-DB-GLPI.ps1 "%MariaBackupFile%" %GLPIDatabaseBackupRoot% %MariaDBHost% %GLPIDatabaseName% %User% %Password% %GLPIDatabaseBackupsRetained%

REM *** Backup Web Application GLPI ***
powershell -ExecutionPolicy RemoteSigned -File %~dp0\Backup-WebApplication-GLPI.ps1 %GLPIWebApplicationBackupRoot% %GLPIWebApplicationPath% %GLPIWebApplicationBackupsRetained%
