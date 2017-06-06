define netscaler::sslservice (
  $ensure                = 'present',
  $cipher_redirect       = undef,
  $cipher_url            = undef,
  $client_auth           = undef,
  $client_cert           = undef,
  $common_name           = undef,
  $dh                    = undef,
  $dh_count              = undef,
  $dh_file               = undef,
  $dh_key_exp_size_limit = undef,
  $dtls_profile_name     = undef,
  $ersa                  = undef,
  $ersa_count            = undef,
  $non_fips_ciphers      = undef,
  $push_enc_trigger      = undef,
  $redirect_port_rewrite = undef,
  $send_close_notify     = undef,
  $server_auth           = undef,
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

  netscaler_sslservice { $name:
    ensure                => $ensure,
    cipher_redirect       => $cipher_redirect,
    cipher_url            => $cipher_url,
    client_auth           => $client_auth,
    client_cert           => $client_cert,
    common_name           => $common_name,
    dh                    => $dh,
    dh_count              => $dh_count,
    dh_file               => $dh_file,
    dh_key_exp_size_limit => $dh_key_exp_size_limit,
    dtls_profile_name     => $dtls_profile_name,
    ersa                  => $ersa,
    ersa_count            => $ersa_count,
    non_fips_ciphers      => $non_fips_ciphers,
    push_enc_trigger      => $push_enc_trigger,
    redirect_port_rewrite => $redirect_port_rewrite,
    send_close_notify     => $send_close_notify,
    server_auth           => $server_auth,
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
    netscaler_sslservice_cipher_binding { $prefixed_ciphers:
      ensure => $ensure,
    }
  }
  if ! empty($prefixed_ecccurves) {
    netscaler_sslservice_ecccurve_binding { $prefixed_ecccurves:
      ensure => $ensure,
    }
  }
  if ! empty($prefixed_certkeys) {
    netscaler_sslservice_certkey_binding { $prefixed_certkeys:
      ensure => $ensure,
    }
  }
}
