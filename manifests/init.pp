class netscaler {
  class { 'netscaler::install': }

  $certificates = hiera_hash('netscaler::certificates', {})
  $servers      = hiera_hash('netscaler::servers', {})
  $services     = hiera_hash('netscaler::services', {})
  $lbvservers   = hiera_hash('netscaler::lbvservers', {})
  $csvservers   = hiera_hash('netscaler::csvservers', {})

  create_resources('netscaler::certificate',  $certificates)
  create_resources('netscaler::server',       $servers)
  create_resources('netscaler::service',      $services)
  create_resources('netscaler::lbvserver',    $lbvservers)
  create_resources('netscaler::csvserver',    $csvservers)
}
