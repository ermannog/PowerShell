# Description
Convert a Word file to PDF, requires Microsoft Word to be installed on computer.

**Version: 1.0 - Date: 03/26/2023**

# Parameters
**InputFile**
Path of the Word file to convert to PDF.

**OutputFile**
Path of the PDF file to generate.

**PDFACompliant**
Switch to generate a PDF/A compliant file (Default value is False).

**Log**
Switch to generate a log file (Default value is False).

# Examples
**EXAMPLE 1:**  *Convert the Test.docx file to PDF by generating the file Test.pdf*

./Convert-WordDocumentToPDF.ps1 -InputFile '".\Test.docx"' -OutputFile '".\Test.pdf"' 

**EXAMPLE 2:**  *Convert the Test.docx file to PDF/A compliant PDF by generating the file Test-A.pdf*

./Convert-WordDocumentToPDF.ps1 -InputFile '".\Test.docx"' -OutputFile '".\Test-A.pdf"' -PDFACompliant
