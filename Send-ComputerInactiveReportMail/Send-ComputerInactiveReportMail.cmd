powershell -ExecutionPolicy RemoteSigned -Command %~dp0Send-ComputerInactiveReportMail.ps1 -MailFrom %COMPUTERNAME%@contoso.com -MailTo storage.alert@contoso.com -SmtpServer mail.contoso.com
