<#
.SYNOPSIS
   Export AD User in Html.
.DESCRIPTION
   This script export AD User in Html.

.PARAMETER UserId
Active Directory username.

.PARAMETER Notes
Annotations.

.PARAMETER PathDirectoryReports
Path where the report will be created.
By default the report is created in the Reports subfolder.

.PARAMETER PathFileCSSSource
Path of the source CSS file used by the report, the file will be copied to the report folder.
By default, the Style.css file in the script folder will be copied into the folder where the report is generated. is generated.

.PARAMETER OpenReport
Opens the report after generating it
By default is False.

.NOTES
   Author:  Ermanno Goletto
   Date:    07/07/2023
   Version: 1.6 
.LINK  
#>

Param(
  [Parameter(Mandatory=$True)]
  [string]$UserId,
  [string]$Note = "",
  [string]$PathDirectoryReports = "",
  [string]$PathFileCSSSource = "",
  [switch]$OpenReport=$false
)

Import-Module ActiveDirectory
Set-StrictMode -Version Latest

# Impostazioni Costanti
$ReportDirectoryName = "Reports"
$ReportFileName = $UserID.ToUpper() + $(Get-Date -Format "-yyyyMMdd") + ".html"
$CssFileName = "Style.css"
$DivPageBreak = "<div class='PageBreak-div'></div>"

# Impostazioni Variabili
$ScriptVersion = ((((Get-Help -Full $PSCommandPath).alertSet.alert.Text) -Split '\r?\n').Trim() | Select-String -Pattern 'Version:').ToString().Replace("Version:","").Trim()

If ($PathDirectoryReports -eq "") {$PathDirectoryReports = Join-Path ($PSScriptRoot) ($ReportDirectoryName)}
$PathFileReport = Join-Path ($PathDirectoryReports) ($ReportFileName)

$CssUri = $CssFileName
If ($PathFileCSSSource -eq "") {$PathFileCSSSource = Join-Path ($PSScriptRoot) ($CssFileName)}
$PathFileCSSDestination = Join-Path ($PathDirectoryReports) ($CssFileName)

$Message = ""

$ReportTitle=""
$ReportSezioneGenerale = ""
$ReportSezioneGeneraleList = New-Object System.Collections.ArrayList
$ReportSezioneAccount = ""
$ReportSezioneAccountList = New-Object System.Collections.ArrayList
$ReportSezioneProfilo = ""
$ReportSezioneProfiloList = New-Object System.Collections.ArrayList
$ReportSezioneTelefoni = ""
$ReportSezioneTelefoniList = New-Object System.Collections.ArrayList
$ReportSezioneOrganizzazione = ""
$ReportSezioneOrganizzazioneList = New-Object System.Collections.ArrayList
$ReportSezioneIndirizzo = ""
$ReportSezioneIndirizzoList = New-Object System.Collections.ArrayList
$ReportSezioneOggetto = ""
$ReportSezioneOggettoList = New-Object System.Collections.ArrayList
$ReportSezioneMemberOf = ""
$ReportSezioneMemberOfList = New-Object System.Collections.ArrayList
$ReportBody = ""
$Report = ""

Try {
  Write-Host "Ricerca utente $UserId ..." -ForegroundColor Blue

  # Esecuzione query utente in Active Directory
  $ADUser = Get-ADUser $UserId -Properties *, msDS-PrincipalName, msDS-SupportedEncryptionTypes, msDS-UserPasswordExpiryTimeComputed

  Write-Host "Creazione report html ..." -ForegroundColor Blue


  # Titolo Report
  $ReportTitle = "Report Utente Active Directory " + $UserID.ToUpper()

  # Sezione Generale Body Report
  $ReportSezioneGeneraleList.Add([PSCustomObject]@{'<b>Nome</b>'= $ADUser.GivenName
                                                   '<b>Cognome</b>' =$ADUser.sn
                                                   '<b>Nome visualizzato</b>' = $ADUser.DisplayName
                                                   '<b>Descrizione</b>' = $ADUser.Description
                                                   '<b>Ufficio</b>' = $ADUser.physicalDeliveryOfficeName
                                                   '<b>telephoneNumber</b>' = $ADUser.telephoneNumber
                                                   '<b>Posta elettronica</b>' = $ADUser.mail
                                                   '<b>Pagina Web</b>' = $ADUser.wWWHomePage}) | Out-Null

  $ReportSezioneGenerale = $ReportSezioneGeneraleList | ConvertTo-Html -As List -Fragment -PreContent "<h2>Generale</h2>"

  # Sezione Account Body Report
  $LogonHours=""
  If ($ADUser.logonHours -ne $null) {$LogonHours = [System.Text.Encoding]::ASCII.GetString([System.Text.Encoding]::Unicode.GetBytes($ADUser.logonHours))}
  
  $AccountExpires = "Mai"
  If($ADUser.AccountExpires -ne 0 -And $ADUser.AccountExpires -ne [Int64]::MaxValue){$AccountExpires = ([datetime]::FromFileTime($ADUser.AccountExpires)).ToUniversalTime().ToString("dddd dd MMMM yyyy HH:mm:ss")}

  $ReportSezioneAccountList.Add([PSCustomObject]@{'<b>Nome accesso utente</b>' = $ADUser.UserPrincipalName
                                                  '<b>Nome accesso utente (precente a Windows 2000)</b>' = $ADUser.'msDS-PrincipalName'
                                                  '<b>Accedi a...</b>' = $ADUser.userWorkstations
                                                  '<b>Orario di accesso...</b>' = $LogonHours
                                                  '<b>Cambiamento obbligatorio password</b>' = ($ADUser.pwdLastSet -eq 0)
                                                  '<b>Cambiamento password non consentito</b>' = $ADUser.CannotChangePassword
                                                  '<b>Nessuna scadenza password</b>' = $ADUser.passwordNeverExpires
                                                  '<b>Archivia password mediante crittografia reversibile</b>' = $ADUser.AllowReversiblePasswordEncryption
                                                  '<b>Account disabilitato</b>' = -Not $ADUser.Enabled
                                                  '<b>Per l''accesso interattivo occorre una smartcard</b>' = (($ADUser.UserAccountControl -band 262144) -ne 0)
                                                  '<b>L''account è sensibile e non può essere delegato</b>' = (($ADUser.UserAccountControl -band 1048576) -ne 0)
                                                  '<b>Usa solo tipi di crittografia DES Kerberos per questo account</b>' = (($ADUser.UserAccountControl -band 2097152) -ne 0)
                                                  '<b>Questo account supporta la crittografia AES 128 bit Kerberos</b>' = (($ADUser.'msDS-SupportedEncryptionTypes' -band 8) -ne 0)
                                                  '<b>Questo account supporta la crittografia AES 256 bit Kerberos</b>' = (($ADUser.'msDS-SupportedEncryptionTypes' -band 16) -ne 0)
                                                  '<b>Non richiedere l''autenticazione preliminare Kerberos</b>' = (($ADUser.UserAccountControl -band 4194304) -ne 0)
                                                  '<b>Scadenza account</b>' = $AccountExpires
                                                  '<b>Account bloccato</b>' = $ADUser.LockedOut}) | Out-Null

  $ReportSezioneAccount = $ReportSezioneAccountList | ConvertTo-Html -As List -Fragment -PreContent "<h2>Account</h2>"

  # Sezione Profilo Body Report
  $ReportSezioneProfiloList.Add([PSCustomObject]@{'<b>Percorso profilo</b>' = $ADUser.profilePath
                                                  '<b>Script di acesso</b>' = $ADUser.scriptPath
                                                  '<b>Percorso locale</b>' =  $ADUser.homeDirectory
                                                  '<b>Connetti</b>' = $ADUser.homeDrive}) | Out-Null
  
  $ReportSezioneProfilo = $ReportSezioneProfiloList | ConvertTo-Html -As List -Fragment -PreContent "<h2>Profilo</h2>"

  # Sezione Telefoni Body Report
  $ReportSezioneTelefoniList.Add([PSCustomObject]@{'<b>Abilitazione</b>' = $ADUser.homePhone
                                                   '<b>Cercapersone</b>' = $ADUser.pager
                                                   '<b>Cellulare</b>' = $ADUser.mobile
                                                   '<b>Fax</b>' = $ADUser.facsimileTelephoneNumber
                                                   '<b>Telefono IP</b>' =  $ADUser.ipPhone
                                                   '<b>Note</b>' = $ADUser.info}) | Out-Null
  
  $ReportSezioneTelefoni = $ReportSezioneTelefoniList | ConvertTo-Html -As List -Fragment -PreContent "<h2>Telefoni</h2>"

  # Sezione Organizzazione Body Report
  $Manager=""
  If($ADUser.manager -ne $null){$Manager=(Get-ADUser ($ADUser.manager) -Property DisplayName).DisplayName + " (" + $ADUser.manager + ")"}

  $DirectReports=""
  If($ADUser.directReports -ne $null){$DirectReports = (($ADUser.directReports | Get-ADUser -Property DisplayName).DisplayName) -Join ", "}

 
  $ReportSezioneOrganizzazioneList.Add([PSCustomObject]@{'<b>Posizione</b>' = $ADUser.title
                                                         '<b>Reparto</b>' = $ADUser.department
                                                         '<b>Nome società</b>' = $ADUser.company
                                                         '<b>Manager</b>' = $Manager
                                                         '<b>Subalterni</b>' =  $DirectReports}) | Out-Null
  
  $ReportSezioneOrganizzazione = $ReportSezioneOrganizzazioneList | ConvertTo-Html -As List -Fragment -PreContent "<h2>Organizzazione</h2>"

  # Sezione Indirizzo Body Report
  $ReportSezioneIndirizzoList.Add([PSCustomObject]@{'<b>Posizione</b>' = $ADUser.title
                                                    '<b>Casella postale</b>' = $ADUser.postOfficeBox -Join ", "
                                                    '<b>Città</b>' = $ADUser.l
                                                    '<b>Provincia</b>' = $ADUser.st
                                                    '<b>CAP</b>' =  $ADUser.postalCode
                                                    '<b>Paese/area geografica</b>' = $ADUser.co}) | Out-Null
  
  $ReportSezioneIndirizzo = $ReportSezioneIndirizzoList | ConvertTo-Html -As List -Fragment -PreContent "<h2>Indirizzo</h2>"

  # Sezione Oggetto Body Report
  $ReportSezioneOggettoList.Add([PSCustomObject]@{'<b>Nome canonico dell''oggetto</b>' = $ADUser.canonicalName
                                                  '<b>Classe oggetto</b>' = $ADUser.objectClass -Join "; "
                                                  '<b>Data creazione</b>' = $ADUser.createTimeStamp
                                                  '<b>Data modifica</b>' = $ADUser.modifyTimeStamp
                                                  '<b>Numero di sequenza di aggiornamento (USN) - Correnti</b>' =  $ADUser.uSNChanged
                                                  '<b>Numero di sequenza di aggiornamento (USN) - Originali</b>' =  $ADUser.uSNCreated
                                                  '<b>Proteggi oggetto da eliminazioni accidentali</b>' = ($ADUser | Get-ADObject -Property ProtectedFromAccidentalDeletion).ProtectedFromAccidentalDeletion
                                                  '<b>Ultimo logon</b>' = $ADUser.LastLogonDate
                                                  '<b>Ultima modifica password</b>' = $ADUser.PasswordLastSet
                                                  '<b>Ultimo logon con password non valida</b>' = $ADUser.LastBadPasswordAttempt
                                                  '<b>Scadenza Password</b>' = [datetime]::FromFileTime($ADUser."msDS-UserPasswordExpiryTimeComputed")
                                                  '<b>SID</b>' = $ADUser.objectSid}) | Out-Null
  
  $ReportSezioneOggetto = $ReportSezioneOggettoList | ConvertTo-Html -As List -Fragment -PreContent "<h2>Oggetto</h2>"


  # Sezione Membro di Body Report
  $PrimaryGroup = ($ADUser.PrimaryGroup) | Get-ADGroup -Property Description, MemberOf
  
  $PrimaryGroupMemberOf = ""
  If ($PrimaryGroup.MemberOf -ne $null) {$PrimaryGroupMemberOf = ($PrimaryGroup.MemberOf | Get-ADGroup).Name -Join ", "}
  
  $ReportSezioneMemberOfList.Add([PSCustomObject]@{'Nome' = $PrimaryGroup.Name; 'Tipo' = 'Primary'; 'Categoria' = $PrimaryGroup.GroupCategory; 'Ambito' = $PrimaryGroup.GroupScope; 'Descrizione' = $PrimaryGroup.Description; 'Membro di' = $PrimaryGroupMemberOf}) | Out-Null

  ForEach($member In ($ADUser.MemberOf | Sort)){
    $memberGroup = ($member) | Get-ADGroup -Property Description, MemberOf
    
    $memberGroupMemberOf = ""
    If ($memberGroup.MemberOf -ne $null) {$memberGroupMemberOf = ($memberGroup.MemberOf | Get-ADGroup).Name -Join ", "}
    
    $ReportSezioneMemberOfList.Add([PSCustomObject]@{'Nome' = $memberGroup.Name; 'Tipo' = ''; 'Categoria' = $memberGroup.GroupCategory; 'Ambito' = $memberGroup.GroupScope; 'Descrizione' = $memberGroup.Description; 'Membro di' = $memberGroupMemberOf}) | Out-Null
  }

  $MembersIncludeNested = Get-ADGroup -LDAPFilter "(member:1.2.840.113556.1.4.1941:=$ADUser)" -Property Description
  ForEach($memberGroup In $MembersIncludeNested | Sort){
    If (-Not ($ADUser.MemberOf -contains $memberGroup)){
      $memberGroupMemberOf = ""
      If ($memberGroup.MemberOf -ne $null) {$memberGroupMemberOf = ($memberGroup.MemberOf | Get-ADGroup).Name -Join ", "}

      $ReportSezioneMemberOfList.Add([PSCustomObject]@{'Nome' = $memberGroup.Name; 'Tipo' = 'Nested'; 'Categoria' = $memberGroup.GroupCategory; 'Ambito' = $memberGroup.GroupScope; 'Descrizione' = $memberGroup.Description; 'Membro di' = $memberGroupMemberOf}) | Out-Null
    }
  }
  
  $ReportSezioneMemberOf = $ReportSezioneMemberOfList | ConvertTo-Html -As Table -Fragment -PreContent ("<h2>Membro di " + $ReportSezioneMemberOfList.Count + " gruppi</h2>")
  $ReportSezioneMemberOf = $ReportSezioneMemberOf.Replace('<table>','<table class="MemberOf-table">')
  $ReportSezioneMemberOf = $ReportSezioneMemberOf.Replace('<td>','<td class="MemberOf-td">')
  $ReportSezioneMemberOf = $ReportSezioneMemberOf.Replace('<th>','<th class="MemberOf-th">')
 
  # Composizione Body Report
  $ReportBody = "<h1>$ReportTitle</h1>"
  $ReportBody += "<table style=""width: 100%;""><tr><td style=""width: 100%;""><b>Annotazioni: </b><i>$Note</i></td><td style=""width: auto; white-space: nowrap;""><b>$(Get-Date -Format "dddd dd MMMM yyyy alle ore HH:mm:ss")</b></td></table>"
  $ReportBody += "$ReportSezioneGenerale"
  $ReportBody += " $ReportSezioneAccount"
  $ReportBody += " $ReportSezioneProfilo"
  $ReportBody += " $ReportSezioneTelefoni"
  $ReportBody += " $ReportSezioneOrganizzazione"
  $ReportBody += " $ReportSezioneIndirizzo"
  $ReportBody += " $DivPageBreak $ReportSezioneOggetto"
  $ReportBody += " $ReportSezioneMemberOf"

  # PostContent Report
  $PostContent = "<br><div style=""float: right;""><p><i>Report creato dall'utente <b>$env:USERNAME</b> sul computer <b>$env:COMPUTERNAME</b> (Script version: $ScriptVersion)</i></p></div>"
  
  # Composizione Report
  $Report = ConvertTo-HTML -CssUri $CssUri -Body $ReportBody -Title $ReportTitle -PostContent $PostContent

  # Creazione Directory Reports
  If (-Not (Test-Path $PathDirectoryReports)) {New-Item $PathDirectoryReports -ItemType Directory | Out-Null} 
  
  # Creazione file Report
  $Report | Out-File $PathFileReport -encoding default
  Write-Host "Creazione report html $PathFileReport eseguita" -ForegroundColor Green

  # Copia File CSS
  Copy-Item -Path $PathFileCSSSource -Destination $PathFileCSSDestination
  Write-Host "Copia file css $PathFileCSSSource in $PathFileCSSDestination eseguita" -ForegroundColor Green

  # Apertura Report
  If($OpenReport){Invoke-Item $PathFileReport}
}
Catch{
  Write-Host "Errore: $PSItem.Exception.Message" -ForegroundColor Red
  IF($PSItem.Exception.InnerException -ne $null){Write-Host $PSItem.Exception.InnerException -ForegroundColor Red}
  Write-Host $PSItem.ScriptStackTrace -ForegroundColor Red
  Exit 1
}