# IP Adresses

**List of IPv4 addresses:**

*`((Get-NetIPConfiguration).IPv4Address).IPAddress`*

**List of IPv4 addresses with subnet mask bits and Interface associated:**

*`Get-NetIPConfiguration).IPv4Address | Select-Object IPAddress, PrefixLength, InterfaceAlias`*

**Comma separated list of IPv4 addresses with subnet mask bits:**

*`((Get-NetIPConfiguration).IPv4Address | Select -Property @{Name=’IPv4Address’; Expression={$_.IPAddress + “/” + $_.PrefixLength}} | Select -ExpandProperty IPv4Address) -Join “, “`*
