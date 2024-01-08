# Variabili di utilità
$timeStamp = Get-Date -format "yyyy-MM-dd-HH-mm-ss" 

# Impostazioni di configurazione
$certFriendlyName = "Certificato Self-Signed per DevAdmin [$timeStamp]"
$certSubject = "C=IT, ST=Cuneo, L=Cuneo, O=DevAdmin, OU=Servizi IT, CN=srvtest01.devadmin.it"
$certExportPath = Join-Path -Path $PSScriptRoot -ChildPath "Certs"
$certExportFileName = "srvtest01.pem"
$certDurationMonths = 120
$certKeyLength = 2048
$certKeyAlgorithm = "RSA"
$certKeySpec = "Signature"
$certKeyUsage = "CertSign"
$certHashAlgorithm = "SHA256"
$certProvider = "Microsoft Enhanced RSA and AES Cryptographic Provider"

# Creazione Certificato autofirmato 
$cert=New-SelfSignedCertificate -FriendlyName $certFriendlyName -Subject $certSubject `
      -CertStoreLocation Cert:\CurrentUser\My `
      -NotAfter (Get-Date).AddMonths($certDurationMonths) `
      -KeyAlgorithm $certKeyAlgorithm -KeyLength $certKeyLength -HashAlgorithm $certHashAlgorithm `
      -KeySpec $certKeySpec -KeyUsage $certKeyUsage `
      -KeyExportPolicy Exportable `
      -Provider $certProvider

# Conversione della Public Key in Base64
$certPublicKeyBase64 = [System.Convert]::ToBase64String($cert.RawData, [System.Base64FormattingOptions]::InsertLineBreaks)

# Conversione della Private Key in Base64
$certRSAPrivateKey = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
$certPrivateKeyBytes = $certRSAPrivateKey.Key.Export([System.Security.Cryptography.CngKeyBlobFormat]::Pkcs8PrivateBlob)
$certPrivateKeyBase64 = [System.Convert]::ToBase64String($certPrivateKeyBytes, [System.Base64FormattingOptions]::InsertLineBreaks)

# Creazione directory per esportazione certificati
New-Item -Path $certExportPath -ItemType Directory -Force

# Export Certificato e della Chiave Privata su file PEM
$certPEMFilePath = Join-Path -Path $certExportPath -ChildPath ($certExportFileName)

$certPEMFileContent = "-----BEGIN PRIVATE KEY-----"
$certPEMFileContent += "`n"
$certPEMFileContent += $certPrivateKeyBase64
$certPEMFileContent += "`n"
$certPEMFileContent += "-----END PRIVATE KEY-----"
$certPEMFileContent += "`n"
$certPEMFileContent += "-----BEGIN CERTIFICATE-----"
$certPEMFileContent += "`n"
$certPEMFileContent += $certPublicKeyBase64
$certPEMFileContent += "`n"
$certPEMFileContent += '-----END CERTIFICATE-----'
$certPEMFileContent += "`n"


$certPEMFileContent| Out-File -FilePath $certPEMFilePath -Encoding Ascii

# Rimozione del certificato dallo store dei cetificati
Remove-Item -Path Cert:\CurrentUser\My\$cert.Thumbprint

