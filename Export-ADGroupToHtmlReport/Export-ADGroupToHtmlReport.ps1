<#
.SYNOPSIS
   Export AD Group in Html.
.DESCRIPTION
   This script export AD User in Html.

.PARAMETER GroupId
Active Directory group name.

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
   Date:    06/07/2023
   Version: 1.2 
.LINK  
#>

Param(
  [Parameter(Mandatory=$True)]
  [string]$GroupId,
  [string]$Note = "",
  [string]$PathDirectoryReports = "",
  [string]$PathFileCSSSource = "",
  [switch]$OpenReport=$false
)

Import-Module ActiveDirectory
Set-StrictMode -Version Latest

# Impostazioni Costanti
$ReportDirectoryName = "Reports"
$ReportFileName = $GroupId.ToUpper() + $(Get-Date -Format "-yyyyMMdd") + ".html"
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
$ReportSezioneOggetto = ""
$ReportSezioneOggettoList = New-Object System.Collections.ArrayList
$ReportSezioneMembersUser = ""
$ReportSezioneMembersUserList = New-Object System.Collections.ArrayList
$ReportSezioneMembersGroup = ""
$ReportSezioneMembersGroupList = New-Object System.Collections.ArrayList
$ReportSezioneMemberOf = ""
$ReportSezioneMemberOfList = New-Object System.Collections.ArrayList
$ReportBody = ""
$Report = ""

Try {
  Write-Host "Ricerca gruppo $GroupId ..." -ForegroundColor Blue

  # Esecuzione query gruppo in Active Directory
  $ADGroup = Get-ADGroup $GroupId -Properties *

  Write-Host "Creazione report html ..." -ForegroundColor Blue


  # Titolo Report
  $ReportTitle = "Report Gruppo Active Directory " + $GroupId.ToUpper()

  # Sezione Generale Body Report
  $ReportSezioneGeneraleList.Add([PSCustomObject]@{'<b>Nome</b>'= $ADGroup.GivenName
                                                   '<b>Descrizione</b>' = $ADGroup.Description
                                                   '<b>Posta elettronica</b>' = $ADGroup.mail
                                                   '<b>Abito</b>' =$ADGroup.GroupScope
                                                   '<b>Categoria</b>' = $ADGroup.GroupCategory
                                                   '<b>Note</b>' = $ADGroup.Info}) | Out-Null

  $ReportSezioneGenerale = $ReportSezioneGeneraleList | ConvertTo-Html -As List -Fragment -PreContent "<h2>Generale</h2>"

  # Sezione Oggetto Body Report
  $ReportSezioneOggettoList.Add([PSCustomObject]@{'<b>Nome canonico dell''oggetto</b>' = $ADGroup.canonicalName
                                                  '<b>Classe oggetto</b>' = $ADGroup.objectClass -Join "; "
                                                  '<b>Data creazione</b>' = $ADGroup.createTimeStamp
                                                  '<b>Data modifica</b>' = $ADGroup.modifyTimeStamp
                                                  '<b>Numero di sequenza di aggiornamento (USN) - Correnti</b>' =  $ADGroup.uSNChanged
                                                  '<b>Numero di sequenza di aggiornamento (USN) - Originali</b>' =  $ADGroup.uSNCreated
                                                  '<b>Proteggi oggetto da eliminazioni accidentali</b>' = ($ADGroup | Get-ADObject -Property ProtectedFromAccidentalDeletion).ProtectedFromAccidentalDeletion
                                                  '<b>SID</b>' = $ADGroup.objectSid}) | Out-Null
  
  $ReportSezioneOggetto = $ReportSezioneOggettoList | ConvertTo-Html -As List -Fragment -PreContent "<h2>Oggetto</h2>"


  # Sezione Membri Users Body Report
  ForEach($member In (Get-ADGroupMember -Identity $ADGroup -Recursive | Where-Object {$_.objectClass -eq "user"} | Sort)){
    $memberNested = -Not($ADGroup.Members -contains $member)
    $ReportSezioneMembersUserList.Add([PSCustomObject]@{'Account' = $member.SamAccountName
                                                        'Nome' = $member.Name
                                                        'Tipo' = @('','Nested')[$memberNested]}) | Out-Null
  }

  $ReportSezioneMembersUser = $ReportSezioneMembersUserList | ConvertTo-Html -As Table -Fragment -PreContent ("<h2>Membri di tipo Utente (" + $ReportSezioneMembersUserList.Count + ")</h2>")
  $ReportSezioneMembersUser = $ReportSezioneMembersUser.Replace('<table>','<table class="Member-table">')
  $ReportSezioneMembersUser = $ReportSezioneMembersUser.Replace('<td>','<td class="Member-td">')
  $ReportSezioneMembersUser = $ReportSezioneMembersUser.Replace('<th>','<th class="Member-th">')


  # Sezione Membri Group Body Report
  ForEach($member In (Get-ADGroup -LDAPFilter "(memberof:1.2.840.113556.1.4.1941:=$ADGroup)" | Sort)){
    $memberNested = -Not($ADGroup.Members -contains $member)
    $ReportSezioneMembersGroupList.Add([PSCustomObject]@{'Nome' = $member.Name
                                                         'Tipo' = @('','Nested')[$memberNested]
                                                         'Categoria' = $member.GroupCategory
                                                         'Ambito' = $member.GroupScope
                                                         'Descrizione' = $member.Description}) | Out-Null
  }

  $ReportSezioneMembersGroup = $ReportSezioneMembersGroupList | ConvertTo-Html -As Table -Fragment -PreContent ("<h2>Membri di tipo Gruppo (" + $ReportSezioneMembersGroupList.Count + ")</h2>")
  $ReportSezioneMembersGroup = $ReportSezioneMembersGroup.Replace('<table>','<table class="Member-table">')
  $ReportSezioneMembersGroup = $ReportSezioneMembersGroup.Replace('<td>','<td class="Member-td">')
  $ReportSezioneMembersGroup = $ReportSezioneMembersGroup.Replace('<th>','<th class="Member-th">')


  # Sezione Membro di Body Report
  ForEach($member In ($ADGroup.MemberOf | Sort)){
    $memberGroup = ($member) | Get-ADGroup -Property Description, MemberOf
    
    $memberGroupMemberOf = ""
    If ($memberGroup.MemberOf -ne $null) {$memberGroupMemberOf = ($memberGroup.MemberOf | Get-ADGroup).Name -Join ", "}
    
    $ReportSezioneMemberOfList.Add([PSCustomObject]@{'Nome' = $memberGroup.Name; 'Tipo' = ''; 'Categoria' = $memberGroup.GroupCategory; 'Scope' = $memberGroup.GroupScope; 'Descrizione' = $memberGroup.Description; 'Membro di' = $memberGroupMemberOf}) | Out-Null
  }

  $MembersIncludeNested = Get-ADGroup -LDAPFilter "(member:1.2.840.113556.1.4.1941:=$ADGroup)" -Property Description
  ForEach($memberGroup In $MembersIncludeNested | Sort){
    If (-Not ($ADGroup.MemberOf -contains $memberGroup)){
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
  $ReportBody += " $DivPageBreak $ReportSezioneOggetto"
  $ReportBody += " $ReportSezioneMembersUser"
  $ReportBody += " $ReportSezioneMembersGroup"
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