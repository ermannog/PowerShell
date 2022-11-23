# Description
This script send an email with the list of inactive computers.

**Version: 1.0 - Date: 27/10/2022**

# Parameters

**DaysUntilComputerInactive**

Specifies the number of days until the computer is inactive. This parameter is optional, the default value is 180.

**ExcludePasswordNeverExpires**

Specifies to excludes computers with the PasswordNeverExpiresproperty set to True. This parameter is optional, the default value is True.

**MailFrom**

Specifies the address from which the mail is sent. Enter a name (optional) and email address, such as Name <someone@example.com>. This parameter is required.

**MailTo**

Specifies the addresses to which the mail is sent. Enter names (optional) and the email address, such as Name <someone@example.com>. This parameter is required.

**SmtpServer**

Specifies the name of the SMTP server that sends the email message. This parameter is required.
