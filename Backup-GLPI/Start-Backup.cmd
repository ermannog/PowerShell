REM *** Impostazioni di configurazione Generale ***
SET MariaBackupFile=%ProgramFiles%\MariaDB 10.2\bin\mariabackup.exe
SET MariaDBHost=.
SET User=root
SET Password=P@assW0rd!

REM *** Impostazioni di configurazione Backup MariaDB ***
SET BackupMariaDBRoot=Z:\Backup-MariaDB
SET MariaDBBackupsRetained=30

REM *** Impostazioni di configurazione Backup Database GLPI ***
SET BackupGLPIDatabaseRoot=Z:\Backup-DB-GLPI
SET GLPIDatabaseName=glpi
SET GLPIDatabaseName=30

REM *** Backup MariaDB ***
powershell -ExecutionPolicy RemoteSigned -File %~dp0\Backup-MariaDB.ps1 "%MariaBackupFile%" %BackupMariaDBRoot% %MariaDBHost% %User% %Password% %MariaDBBackupsRetained%

REM *** Backup Database GLPI ***powershell -ExecutionPolicy RemoteSigned -File %~dp0\Backup-DB-GLPI.ps1 "%MariaBackupFile%" %BackupGLPIDatabaseRoot% %MariaDBHost% %GLPIDatabaseName% %User% %Password% 
%GLPIDBBackupsRetained%
