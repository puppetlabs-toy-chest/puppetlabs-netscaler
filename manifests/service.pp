define netscaler::service (
  $server_name,
  $port,
  $protocol,
  $ensure              = 'present',
  $client_ip           = undef,
  $client_ip_header    = undef,
  $max_clients         = undef,
  $max_requests        = undef,
  $use_source_ip       = undef,
  $use_proxy_port      = undef,
  $surge_protection    = undef,
  $client_idle_timeout = undef,
  $server_idle_timeout = undef,
  $client_keepalive    = undef,
  $tcp_buffering       = undef,
  $use_compression     = undef,
  $appflow_logging     = undef,
  $monitors            = undef,
  $ssl                 = {},
) {
  notice("Creating service ${name}")

  $prefixed_monitors = prefix($monitors, "${name}/")

  $ssl_service_types = [
    'SSL',
  ]

  if !empty($ssl) or member($ssl_service_types, $service_type) {
    $uses_ssl = true
  } else {
    $uses_ssl = false
  }

  netscaler_service { $name:
    ensure              => $ensure,
    server_name         => $server_name,
    port                => "${port}",
    protocol            => $protocol,
    client_ip           => $client_ip,
    client_ip_header    => $client_ip_header,
    max_clients         => $max_clients,
    max_requests        => $max_requests,
    use_source_ip       => $use_source_ip,
    use_proxy_port      => $use_proxy_port,
    surge_protection    => $surge_protection,
    client_idle_timeout => $client_idle_timeout,
    server_idle_timeout => $server_idle_timeout,
    client_keepalive    => $client_keepalive,
    tcp_buffering       => $tcp_buffering,
    use_compression     => $use_compression,
    appflow_logging     => $appflow_logging,
  }

  if $uses_ssl {
    $ssl_resource = {
      "${name}" => $ssl,
    }

    create_resources('netscaler::sslservice',  $ssl_resource)
  }

  if ! empty($prefixed_monitors) {
    netscaler_service_lbmonitor_binding { $prefixed_monitors:
      ensure => $ensure,
    }
  }
}
