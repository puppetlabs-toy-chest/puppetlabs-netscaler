define netscaler::csvserver (
  $service_type,
  $default_lbvserver,
  $ensure          = 'present',
  $ip_address      = '0.0.0.0',
  $port            = '0',
  $client_timeout  = undef,
  $listen_policy   = undef,
  $appflow_logging = undef,
  $ssl             = {}
) {
  notice("Creating csvserver ${name}")

  $ssl_service_types = [
    'SSL',
  ]

  if !empty($ssl) or member($ssl_service_types, $service_type) {
    $uses_ssl = true
  } else {
    $uses_ssl = false
  }

  netscaler_csvserver { $name:
    ensure            => $ensure,
    ip_address        => $ip_address,
    port              => "${port}",
    service_type      => $service_type,
    default_lbvserver => $default_lbvserver,
    client_timeout    => $client_timeout,
    listen_policy     => $listen_policy,
    appflow_logging   => $appflow_logging,
  }

  if $uses_ssl {
    $ssl_resource = {
      "${name}" => $ssl,
    }

    create_resources('netscaler::sslvserver',  $ssl_resource)
  }
}
