# IP Adresses

**List of IPv4 addresses:**
*`((Get-NetIPConfiguration).IPv4Address).IPAddress`*

**List of IPv4 addresses with subnet mask bits and Interface associated:**

*`Get-NetIPConfiguration).IPv4Address | Select-Object IPAddress, PrefixLength, InterfaceAlias`*
