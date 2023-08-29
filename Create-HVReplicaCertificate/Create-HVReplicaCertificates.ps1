# Impostazioni Variabili
$rootCAName = "Root CA Hyper-V Replica"
$certSrvHVPrimaryName = "srvhv01.contoso.com"
$certSrvHVSecondaryName = "srvhv02.contoso.com"
$certPassword = 'StrongPassword!' | ConvertTo-SecureString -Force -AsPlainText
$certKeyLength = 2048
$certFolder = Join-Path -Path $PSScriptRoot -ChildPath "Certs"

## Creazione directory per esportazione certificati
If (-Not (Test-Path $certFolder)) { New-Item -Path $certFolder -ItemType Directory -Force }


## Check certificato Root CA nello store Personale del certificati dell'utente corrente esistente
$certRootCA = Get-ChildItem -path Cert:\CurrentUser\My | Where {$_.FriendlyName -eq $rootCAName}

If ($certRootCA -ne $null) {
  Write-Host "Rimozione certificato per Root CA esistente"
  $certRootCA | Remove-Item
} 


## Creazione certificato Root CA nello store Personale del certificati dell'utente corrente
$certRootCA = New-SelfSignedCertificate `
                -Subject $rootCAName  `
                -FriendlyName $rootCAName `
                -KeyExportPolicy Exportable  `
                -KeyUsage CertSign  `
                -KeyLength $certKeyLength  `
                -KeyUsageProperty All  `
                -KeyAlgorithm 'RSA'  `
                -HashAlgorithm 'SHA256'  `
                -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"  `
                -NotAfter (Get-Date).AddYears(20) `
                -CertStoreLocation Cert:\CurrentUser\My


## Export del certificato Root CA
$certRootCAFilePath = "$certFolder\$($rootCAName).pfx"
$certRootCA | Export-PfxCertificate -FilePath $certRootCAFilePath -Password $certPassword -Force


## Check certificato per Server Primario nello store Personale del certificati dell'utente corrente esistente
$certSrvHVPrimary = Get-ChildItem -path Cert:\CurrentUser\My | Where {$_.FriendlyName -eq $certSrvHVPrimaryName}
If ($certSrvHVPrimary -ne $null) {
  Write-Host "Rimozione certificato per Server Primario esistente"
  $certSrvHVPrimary | Remove-Item
} 


## Creazione certificato per Server Primario
$certSrvHVPrimary =	New-SelfSignedCertificate `
	                  -FriendlyName $certSrvHVPrimaryName `
	                  -Subject $certSrvHVPrimaryName `
	                  -KeyExportPolicy Exportable `
	                  -CertStoreLocation "Cert:\CurrentUser\My" `
	                  -Signer $certRootCA `
	                  -KeyLength 2048  `
	                  -KeyAlgorithm 'RSA'  `
	                  -HashAlgorithm 'SHA256'  `
	                  -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"  `
	                  -NotAfter (Get-Date).AddYears(10)


## Export del certificato per Server Primario
$certSrvHVPrimaryFilePath = "$certFolder\$($certSrvHVPrimaryName).pfx"
$certSrvHVPrimary | Export-PfxCertificate -FilePath $certSrvHVPrimaryFilePath -Password $certPassword -Force


## Check certificato per Server Secondario nello store Personale del certificati dell'utente corrente esistente
$certSrvHVSecondary = Get-ChildItem -path Cert:\CurrentUser\My | Where {$_.FriendlyName -eq $certSrvHVSecondaryName}
If ($certSrvHVSecondary -ne $null) {
  Write-Host "Rimozione certificato per Server Secondario esistente"
  $certSrvHVSecondary | Remove-Item
}


## Creazione certificato per Server Primario
$certSrvHVSecondary = New-SelfSignedCertificate `
	                    -FriendlyName $certSrvHVSecondaryName `
	                    -Subject $certSrvHVSecondaryName `
	                    -KeyExportPolicy Exportable `
	                    -CertStoreLocation "Cert:\CurrentUser\My" `
	                    -Signer $certRootCA `
	                    -KeyLength 2048  `
	                    -KeyAlgorithm 'RSA'  `
	                    -HashAlgorithm 'SHA256'  `
	                    -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"  `
	                    -NotAfter (Get-Date).AddYears(10)

## Export del certificato per Server Secondario
$certSrvHVSecondaryFilePath = "$certFolder\$($certSrvHVSecondaryName).pfx"
$certSrvHVSecondary | Export-PfxCertificate -FilePath $certSrvHVSecondaryFilePath -Password $certPassword -Force