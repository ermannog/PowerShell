# Active Directory

**Check if a user has the AccountExpirationDate set:**

`*(Get-ADUser username -Properties AccountExpirationDate).AccountExpirationDate -eq $null*`
