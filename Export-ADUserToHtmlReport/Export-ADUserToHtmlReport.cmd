@ECHO OFF
CLS
SET UserID=%UserName%
SET /p "UserID=Nome utente (Invio <%UserID%>): "
SET Note=Modifica account
SET /p "Note=Annotazioni (Invio <%Note%>): "

powershell -ExecutionPolicy RemoteSigned -Command %~dp0Export-AdUserToHtmlReport.ps1 -UserId %UserID% -Note '%Note%' -OpenReport

IF %errorlevel% NEQ 0 PAUSE