# Description
This script send an email with the list of inactive computers.

**Version: 1.0 - Date: 27/10/2022 **
# Parameters

**DaysUntilComputerInactive**

Specifies the number of days until the computer is inactive. This parameter is optional, the default value is 180.

**ExcludePasswordNeverExpires**

Specifies to excludes computers with the PasswordNeverExpiresproperty set to True. This parameter is optional, the default value is True.

**From**

Specifies the address from which the mail is sent. Enter a name (optional) and email address, such as Name <someone@example.com>. This parameter is required.

**To**

Specifies the addresses to which the mail is sent. Enter names (optional) and the email address, such as Name <someone@example.com>. This parameter is required.

**SmtpServer**

Specifies the name of the SMTP server that sends the email message. This parameter is required.

# Examples
**EXAMPLE 1:**  *Retreive info of Computer save on a json file in C:\Temp.*

./Send-ComputerInactiveReportMail.ps1 -From %COMPUTERNAME%@contoso.com -To reports@contoso.com -SmtpServer mail.contoso.com
