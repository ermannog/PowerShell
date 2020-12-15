# Active Directory

**Check if a user has the AccountExpirationDate set:**

*`(Get-ADUser username -Properties AccountExpirationDate).AccountExpirationDate -eq $null`*

**List all users password expiration date:**

*`Get-ADUser -Filter * -Properties PasswordLastSet, PasswordNeverExpires | Format-Table Name, PasswordLastSet, PasswordNeverExpires`*

**List of users with passwords expiring in the next 7 days:**

*`Get-ADUser -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "Name", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Name",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | Where-Object {$_.ExpiryDate -ge (Get-Date) -and $_.ExpiryDate -le (Get-Date).AddDays(7)} | Select-Object * | Sort-Object ExpiryDate`*

**List of users with passwords never expires:**

*`Get-ADUser -filter * -Properties Name, PasswordLastSet, PasswordNeverExpires | Where { $_.PasswordNeverExpires -eq $True } | Where {$_.Enabled -eq $True} | Format-Table Name, PasswordLastSet`*

**Check if a user's password has expired:**

*`(Get-ADUser username –Properties "msDS-UserPasswordExpiryTimeComputed" | Select @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}).ExpiryDate -lt (Get-Date)`*

**Get primary group ID and name of a user:**

*`Get-AdUser -Identity username -Properties PrimaryGroupID, PrimaryGroup`*

**Get a user’s Group Memberships:**

*`Get-ADPrincipalGroupMembership -Identity username`*

**Get user's primary group:**

*`Get-ADGroup -Identity (Get-AdUser -Identity username -Properties PrimaryGroup).PrimaryGroup`*
