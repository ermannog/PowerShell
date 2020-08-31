powershell -ExecutionPolicy RemoteSigned -Command %~dp0Send-MPReportMail.ps1 -From %COMPUTERNAME%@contoso.com -SmtpServer mail.contoso.com -To storage.alert@contoso.com
