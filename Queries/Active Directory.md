# Active Directory

**Check if a user has the AccountExpirationDate set:**

*`(Get-ADUser username -Properties AccountExpirationDate).AccountExpirationDate -eq $null`*

**List all users password expiration date:**

*`Get-ADUser -Filter * -Properties PasswordLastSet, PasswordNeverExpires | Format-Table Name, PasswordLastSet, PasswordNeverExpires`*

**List of users with passwords expiring in the next 7 days:**

*`Get-ADUser -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "Name", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Name",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | Where-Object {$_.ExpiryDate -ge (Get-Date) -and $_.ExpiryDate -le (Get-Date).AddDays(7)} | Select-Object * | Sort-Object ExpiryDate`*

**Check if a user's password has expired:***

*`(Get-ADUser username –Properties "msDS-UserPasswordExpiryTimeComputed" | Select @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}).ExpiryDate -lt (Get-Date)`*
