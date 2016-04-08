define netscaler::lbvserver (
  $service_type,
  $ensure                     = 'present',
  $ip_address                 = '0.0.0.0',
  $port                       = '0',
  $persistence_type           = undef,
  $persistence_timeout        = undef,
  $persistence_backup         = undef,
  $backup_persistence_timeout = undef,
  $listen_policy              = undef,
  $client_timeout             = undef,
  $appflow_logging            = undef,
  $services                   = [],
  $ssl                        = {},
) {
  notice("Creating lbvserver ${name}")

  $ssl_service_types = [
    'SSL',
  ]

  if !empty($ssl) or member($ssl_service_types, $service_type) {
    $uses_ssl = true
  } else {
    $uses_ssl = false
  }

  netscaler_lbvserver { $name:
    ensure                     => $ensure,
    ip_address                 => $ip_address,
    port                       => "${port}",
    service_type               => $service_type,
    persistence_type           => $persistence_type,
    persistence_timeout        => $persistence_timeout,
    persistence_backup         => $persistence_backup,
    backup_persistence_timeout => $backup_persistence_timeout,
    listen_policy              => $listen_policy,
    client_timeout             => $client_timeout,
    appflow_logging            => $appflow_logging,
  }

  if $uses_ssl {
    $ssl_resource = {
      "${name}" => $ssl,
    }

    create_resources('netscaler::sslvserver',  $ssl_resource)
  }
}
