define netscaler::server (
  $address,
  $ensure               = 'present',
) {
  notice("Creating server ${name}")

  netscaler_server { $name:
    ensure  => $ensure,
    address => $address,
  }
}
