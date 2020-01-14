powershell -ExecutionPolicy RemoteSigned -Command %~dp0Send-LastDayNewFilesMail.ps1 -Drive "E:" -From %COMPUTERNAME%@contoso.com -SmtpServer mail.contoso.com -To storage.alert@contoso.com
