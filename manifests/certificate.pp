define netscaler::certificate (
  $ensure               = 'present',
  $certificate_filename = "/nsconfig/ssl/${name}.cert",
  $key_filename         = "/nsconfig/ssl/${name}.key",
  $linkcert_keyname     = 'Terena-SSL-CA3-chain',
) {
  netscaler_sslcertkey { $name:
    ensure               => $ensure,
    certificate_filename => $certificate_filename,
    key_filename         => $key_filename,
    linkcert_keyname     => $linkcert_keyname,
  }
}
