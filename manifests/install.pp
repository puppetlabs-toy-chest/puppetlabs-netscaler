# Private class
class netscaler::install {
  if versioncmp('4', $::puppetversion) > 0 {
    $provider = $::puppetversion ? {
      /Puppet Enterprise/ => 'pe_gem',
      default             => 'gem',
    }
  } else {
    #everything later than 4 use puppet_gem
    $provider  = 'puppet_gem'
  }
  notice ("provider: ${$provider}")
  if ! defined(Package['faraday']) {
    package { 'faraday':
      ensure   => present,
      provider => $provider,
    }
  }
}
