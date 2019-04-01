powershell.exe -ExecutionPolicy RemoteSigned -Command %~dp0Execute-WindowsUpdate.ps1 -SendLogByMail -MailFrom %COMPUTERNAME%@contoso.com -MailTo report@contoso.com -SmtpServer mail.contoso.com
pause