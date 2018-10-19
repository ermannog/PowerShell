# Description
This script send mail message with a report generate by a query on Sql Sever.

**Version: 1.0 - Date: 016/10/2018**

# Parameters

**QueryFile**

Specifies a text file that contains the sql query. This parameter is required.

**ServerInstance**

Specifies the name of an instance of the Database Engine. For default instances, only specify the computer name: MyComputer. For named instances, use the format ComputerName\InstanceName. This parameter is optional (the default value is local computer).

**Database**

Specifies the name of a database. This parameter is required.

**Subject**

Specifies the subject of the mail. This parameter is required.

**From**

Specifies the address from which the mail is sent. Enter a name (optional) and email address, such as Name <someone@example.com>. This parameter is required.

**SmtpServer**

Specifies the name of the SMTP server that sends the email message. This parameter is required.

**To**
Specifies the addresses to which the mail is sent. Enter names (optional) and the email address, such as Name <someone@example.com>. This parameter is required.

**OutputToBody**

Specifies if the query output will be inserted in the body of the mail. This parameter is optional (the default value is True).

**LineWidth**

Specifies the number of characters in each line of output. This parameter is optional (the default value is 160).

**AttachCSV**

Specifies specifies if the query output will be attached as a csv file. This parameter is optional (the default value is False).
   
# Examples

./Send-SqlQuerytMail.ps1 -QueryFile 'query.sql' -ConnectionString 'Data Source=localhost;Initial Catalog=AdventureWorks;Integrated Security=SSPI' -Subject 'Report'  -From %COMPUTERNAME%@contoso.com -SmtpServer mail.contoso.com -To sqlrepor@contoso.com
