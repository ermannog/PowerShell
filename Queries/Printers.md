# Printers

**List of Shared and Published Printers:##

*`Get-Printer -ComputerName Hostname | Where Shared -eq True | Where Published -eq True | Select Name, DriverName, PortName, PrinterStatus | FT`*
