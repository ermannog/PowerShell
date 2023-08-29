# Description
Create the certificates needed to set up HTTPS-based Hyper-V replication.

Lo script crea un certificato autofirmato per la Root CA, questo certificato viene creato nell'archivio certificati personali dell'utente con cui viene eseguito lo script, inoltre il certificato viene esportato in formato pfx nella sottocartella Certs.

Next the script creates the certificates for the Primary and Secondary server among which to configure the Hyper-V replica, these certificates are created through the generated Root CA certificate and saved in the personal certificate store of the user with which the script is executed, also the certificates are exported in pfx format in the Cert subfolder.

You can change the settings by which certificates are generated using the variables defined in the initial section of the script.

The certificates are regenerated every time the script is run.
