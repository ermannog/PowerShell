# Active Directory

**Check if a user has the AccountExpirationDate set:**

*`(Get-ADUser username -Properties AccountExpirationDate).AccountExpirationDate -eq $null`*

***List All Users Password Expiration Date:**
*`Get-ADUser -Filter * -Properties PasswordLastSet, PasswordNeverExpires | Format-Table Name, PasswordLastSet, PasswordNeverExpires`*
