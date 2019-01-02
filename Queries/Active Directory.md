# Active Directory

**Check if a user has the AccountExpirationDate set:**

*`(get-aduser __username__ -properties AccountExpirationDate).AccountExpirationDate -eq $null`*
