# Description
This script execute Windows Update on local computer, , the session in which you are running the script must be started with elevated user rights.

**Version: 1.0 - Date: 25/03/2019**

# Parameters

**UpdateType**

Specifies specifies the type of the updates. This parameter is optional (the default value is Software). The allowed values are Software and Driver.

**EndScriptOperation**

Specifies specifies the operation to be performed at the end of the script. This parameter is optional (the default value is None). The allowed values are None, Restart, RestartIfRequired and Shutdown.

**LogFilePath**

Specifies the path of the log files. This parameter is optional (the default value is %SystemDrive%\Logs).

**LogFilesRetained**

Specifies number of log files retained. This parameter is optional (the default value is 30).

**SendLogByMail**

Specifies if send the log by mail. This parameter is optional (the default value is False).

**MailFrom**

Specifies the address from which the mail is sent. Enter a name (optional) and email address, such as Name <someone@example.com>.

**MailTo**

Specifies the addresses to which the mail is sent. Enter names (optional) and the email address, such as Name <someone@example.com>.

**SmtpServer**

Specifies the name of the SMTP server that sends the email message.
   
# Examples

./Execute-WindowsUpdate.ps1 ExecutionPolicy RemoteSigned -Command %~dp0Execute-WindowsUpdate.ps1 -SendLogByMail -MailFrom %COMPUTERNAME%@contoso.com -MailTo report@contoso.com -SmtpServer mail.contoso.com
