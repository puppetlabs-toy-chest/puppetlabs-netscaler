##Type: netscaler_sslservice_certkey_binding

Binds an SSL certificate-key pair or an SSL policy to a certkey.

###Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

####`ca`

Name of the CA certificate that issues and signs the intermediate-CA certificate or the end-user client or server certificate.

####`crl_check`

Rule to use for the CRL corresponding to the CA certificate during client authentication. Available settings function as follows:

* MANDATORY - Deny SSL clients if the CRL is missing or expired, or the Next Update date is in the past, or the CRL is incomplete. 

* OPTIONAL - Allow SSL clients if the CRL is missing or expired, or the Next Update date is in the past, or the CRL is incomplete, but deny if the client certificate is revoked in the CRL.

Possible values: Mandatory, Optional

####`skip_ca_name`

The flag is used to indicate whether this particular CA certificate's CA_Name needs to be sent to the SSL client while requesting for client certificate in a SSL handshake

####`sni_cert`

Name of the certificate-key pair to bind for use in SNI processing.

####`ocsp_check`

Rule to use for the OCSP responder associated with the CA certificate during client authentication. If MANDATORY is specified, deny all SSL clients if the OCSP check fails because of connectivity issues with the remote OCSP server, or any other reason that prevents the OCSP check. With the OPTIONAL setting, allow SSL clients even if the OCSP check fails except when the client certificate is revoked.

Possible values: Mandatory, Optional


