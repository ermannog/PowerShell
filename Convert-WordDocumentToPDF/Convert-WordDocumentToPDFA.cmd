@ECHO OFF
powershell -ExecutionPolicy RemoteSigned -Command %~dp0Convert-WordDocumentToPDF.ps1 -InputFile "%~dp0Test.docx" -OutputFile "%~dp0Test-A.pdf" -PDFACompliant

Pause