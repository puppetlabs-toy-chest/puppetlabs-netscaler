define netscaler::sslvserver (
  $ensure                = 'present',
  $cipher_redirect       = undef,
  $cipher_url            = undef,
  $clear_text_port       = undef,
  $client_auth           = undef,
  $client_cert           = undef,
  $dh                    = undef,
  $dh_file               = undef,
  $dh_count              = undef,
  $dh_key_exp_size_limit = undef,
  $dtls_profile_name     = undef,
  $ersa                  = undef,
  $ersa_count            = undef,
  $non_fips_ciphers      = undef,
  $push_enc_trigger      = undef,
  $redirect_port_rewrite = undef,
  $send_close_notify     = undef,
  $sess_reuse            = undef,
  $sess_timeout          = undef,
  $sni_enable            = undef,
  $ssl2                  = undef,
  $ssl3                  = undef,
  $ssl_profile           = undef,
  $ssl_redirect          = undef,
  $sslv2_redirect        = undef,
  $sslv2_url             = undef,
  $tls1                  = undef,
  $tls11                 = undef,
  $tls12                 = undef,
  $certkeys              = [],
  $ciphers               = [],
  $ecccurves             = [],
) {
  notice("Creating server ${name}")

  $prefixed_ciphers = prefix($ciphers, "${name}/")
  $prefixed_ecccurves = prefix($ecccurves, "${name}/")
  $prefixed_certkeys = prefix($certkeys, "${name}/")

  netscaler_sslvserver { $name:
    ensure                => $ensure,
    cipher_redirect       => $cipher_redirect,
    cipher_url            => $cipher_url,
    clear_text_port       => $clear_text_port,
    client_auth           => $client_auth,
    client_cert           => $client_cert,
    dh                    => $dh,
    dh_file               => $dh_file,
    dh_count              => $dh_count,
    dh_key_exp_size_limit => $dh_key_exp_size_limit,
    dtls_profile_name     => $dtls_profile_name,
    ersa                  => $ersa,
    ersa_count            => $ersa_count,
    non_fips_ciphers      => $non_fips_ciphers,
    push_enc_trigger      => $push_enc_trigger,
    redirect_port_rewrite => $redirect_port_rewrite,
    send_close_notify     => $send_close_notify,
    sess_reuse            => $sess_reuse,
    sess_timeout          => $sess_timeout,
    sni_enable            => $sni_enable,
    ssl2                  => $ssl2,
    ssl3                  => $ssl3,
    ssl_profile           => $ssl_profile,
    ssl_redirect          => $ssl_redirect,
    sslv2_redirect        => $sslv2_redirect,
    sslv2_url             => $sslv2_url,
    tls1                  => $tls1,
    tls11                 => $tls11,
    tls12                 => $tls12,
  }

  if ! empty($prefixed_ciphers) {
    netscaler_sslvserver_cipher_binding { $prefixed_ciphers:
      ensure => $ensure,
    }
  }
  if ! empty($prefixed_ecccurves) {
    netscaler_sslvserver_ecccurve_binding { $prefixed_ecccurves:
      ensure => $ensure,
    }
  }
  if ! empty($prefixed_certkeys) {
    netscaler_sslvserver_sslcertkey_binding { $prefixed_certkeys:
      ensure => $ensure,
    }
  }
}
