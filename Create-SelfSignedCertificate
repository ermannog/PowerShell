# Variabili di utilità
$timeStamp = Get-Date -format "yyyy-MM-dd-HH-mm-ss" 

# Impostazioni di configurazione
$certFriendlyName = "Certificato Self-Signed per firma codice [$timeStamp]"
$certSubject = "O=DevAdmin,L=Cuneo,S=Cuneo,C=IT"
$certExportPath = "C:\Certs"
$certExportFileName = "DevAdminSelfSignedCodeSigning"
$certPFXPassword = "PassW0rd!"
$certDurationMonths = 36
$certKeyLength = 2048
$certHashAlgorithm = "SHA256"
$certKeyUsage = "DigitalSignature"
$certEnhancedKeyUsage = "2.5.29.37={text}1.3.6.1.5.5.7.3.3, 1.3.6.1.5.5.7.3.8"

# Creazione Certificato autofirmato 
$cert=New-SelfSignedCertificate -FriendlyName $certFriendlyName -Subject $certSubject `
      -CertStoreLocation Cert:\CurrentUser\My `
      -NotAfter (Get-Date).AddMonths($certDurationMonths) `
      -KeyAlgorithm RSA -KeyLength $certKeyLength -HashAlgorithm $certHashAlgorithm `
      -KeyUsage $certKeyUsage `
      -TextExtension @("$certEnhancedKeyUsage") `
      -KeyExportPolicy Exportable `
      -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"

# Creazione directory per esportazione certificati
New-Item -Path $certExportPath -ItemType Directory -Force

# Export Certificato su file PFX con entire chain e tutte le external properties
$certPFXFilePath = Join-Path -Path $certExportPath -ChildPath ($certExportFileName + "." +$timeStamp + ".pfx")

$certPassword = ConvertTo-SecureString -String $certPFXPassword -Force –AsPlainText
Export-PfxCertificate -Cert $cert -FilePath $certPFXFilePath -Password $CertPassword

# Export Chiave pubblica su file CER
$certCERFilePath = Join-Path -Path $certExportPath -ChildPath ($certExportFileName + "." +$timeStamp + ".cer")
Export-Certificate -Cert $cert -FilePath $certCERFilePath
