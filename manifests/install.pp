# Private class
class netscaler::install {
  $provider = $::puppetversion ? {
    /Puppet Enterprise/ => 'pe_gem',
    default             => 'gem',
  }
  if ! defined(Package['faraday']) {
    package { 'faraday':
      ensure   => present,
      provider => $provider,
    }
  }
}
