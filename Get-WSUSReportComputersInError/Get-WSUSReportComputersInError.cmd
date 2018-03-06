PowerShell -ExecutionPolicy RemoteSigned -File %~dp0Get-WSUSReportComputersInError.ps1 -SendReportByMail -SmtpServer "mailserver.example.com" -MailFrom "wsus@example.com" -MailTo "alert@example.com"
