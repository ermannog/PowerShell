# Description
This script try access to an Url through a proxy.

**Version: 1.0 - Date: 29/11/2018**

# Parameters

**Url**

Specifies the Url to test. This parameter is required.

**ProxyHost**

Specifies the host name or IP address of the proxy. This parameter is required.

**ProxyPort**

Specifies the port of the proxy. This parameter is required.

**UserName**

Specifies the User Name to authenticate with the proxy. This parameter is optional, if not specified will be used the credentials of the currently logged on user.

**Password**

Specifies the Password of User Name to authenticate with the proxy. This parameter is optional.
   
# Examples

./Test-WebProxy.ps1 -Url https://www.microsoft.com -ProxyHost proxy.contoso.com -ProxyPort 8080
./Test-WebProxy.ps1 -Url https://www.microsoft.com -ProxyHost proxy.contoso.com -ProxyPort 8080 -UserName usertest@contoso.com -Password P@assW0rd!
