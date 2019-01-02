# Active Directory

**Check if a user has the AccountExpirationDate set:**

*`(get-aduser *username* -properties AccountExpirationDate).AccountExpirationDate -eq $null`*
