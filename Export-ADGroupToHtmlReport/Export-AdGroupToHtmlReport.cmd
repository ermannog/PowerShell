@ECHO OFF
CLS
REM SET GroupID=Tutti i Dipendenti
SET GroupID=TestUsers
SET /p "GroupID=Nome gruppo (Invio <%GroupID%>): "
SET Note=Modifica gruppo
SET /p "Note=Annotazioni (Invio <%Note%>): "

powershell -ExecutionPolicy RemoteSigned -Command %~dp0Export-AdGroupToHtmlReport.ps1 -GroupId '%GroupID%' -Note '%Note%' -OpenReport

IF %errorlevel% NEQ 0 PAUSE
