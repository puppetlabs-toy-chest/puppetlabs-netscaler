require 'spec_helper_acceptance'

describe 'sslvserver_sslcertkey_binding' do
  #we need to upload a key and cert file, for this test to work
#  it 'makes a sslvserver_sslcertkey_binding' do
#    pp=<<-EOS
#netscaler_file { 'server.cert':
#        ensure       => 'present',
#        content  => '-----BEGIN CERTIFICATE-----
#MIICcTCCAdoCCQCmIBitM/LBozANBgkqhkiG9w0BAQUFADB9MQswCQYDVQQGEwJB
#VTEPMA0GA1UECBMGb3JlZ29uMREwDwYDVQQHEwhwb3J0bGFuZDEMMAoGA1UEChMD
#YmxhMQwwCgYDVQQLEwNvcmcxFDASBgNVBAMTC3d3dy5ibGEuY29tMRgwFgYJKoZI
#hvcNAQkBFgluYSJuYS5jb20wHhcNMTUwMjE2MTIxMjUzWhcNMTYwMjE2MTIxMjUz
#WjB9MQswCQYDVQQGEwJBVTEPMA0GA1UECBMGb3JlZ29uMREwDwYDVQQHEwhwb3J0
#bGFuZDEMMAoGA1UEChMDYmxhMQwwCgYDVQQLEwNvcmcxFDASBgNVBAMTC3d3dy5i
#bGEuY29tMRgwFgYJKoZIhvcNAQkBFgluYSJuYS5jb20wgZ8wDQYJKoZIhvcNAQEB
#BQADgY0AMIGJAoGBAL/zCEBm/UlQS/DJiHdWcHyItsYyiYDjDB4tXOrqRTt4V42v
#Brn6zip/PWOBF+7psn/ATzqk8TiP4L5ktlUMDiCBBxDjAAgUdXoZmppWO3xo/BK5
#74QY9C9/DaESPXx7UqMRacb3LTTlf+ElngtDlRVJ6357texQhtwu/sS7jsc3AgMB
#AAEwDQYJKoZIhvcNAQEFBQADgYEAHJbLp43Nph18cZGjUBDTvQrah8vJAkwEBG9m
#tztalmPid1QWieZuXdnPhr9/dfst5XHZPTjGPnI7LkuEyuiiFkjFF+MkLIHLbP6J
#mbmRBMSkpXBRBZXqrhIVZ9im3sp/fKzAvzl9DZt4PoGzRGSn7clwUT2Z/NM0nuZS
#wxmnhT8=
#-----END CERTIFICATE-----',
#        encoding => 'BASE64',
#}
#netscaler_file { 'server.key':
#       ensure       => 'present',
#       content  => '-----BEGIN RSA PRIVATE KEY-----
#MIICXgIBAAKBgQC/8whAZv1JUEvwyYh3VnB8iLbGMomA4wweLVzq6kU7eFeNrwa5
#+s4qfz1jgRfu6bJ/wE86pPE4j+C+ZLZVDA4ggQcQ4wAIFHV6GZqaVjt8aPwSue+E
#GPQvfw2hEj18e1KjEWnG9y005X/hJZ4LQ5UVSet+e7XsUIbcLv7Eu47HNwIDAQAB
#AoGBAJBqrd6mnhK20ywKtR30bxWDVuCvzTynlsptnucv837XACidcxYiWVMoAGwJ
#CJS8R4xOiE27I7JGrfURmQ1L0KPeXRWmvik9LT12ZiNxxhlDKUg2F53WnLAxVzkd
#dwZ3WkWS8aRNLQhw14DI2R3+qNWP18E+xkaFlK53jwKVd9JhAkEA30xizWgpMUyq
#Kvts1hXQI+TuwvUw2jsXW98gVRJnikkIAc7nNYkjx+rtpJukt8+o8IvFSvzq1T4H
#O8n75LXJRQJBANwPWUVmnETWJOoOFkMlLfS1Dyi3eac2KXJpks2S5gP+jXkGRCxL
#oXseXFtZIZ686E5sMu/Dwa9Pn15rtAcekEsCQQDXmRwocXKcXAZNW9bY2dTOY2M4
#r56MhtNl7Ah+uzdnaF4nyMqqgRAgHa936KNgqkrWfk1uusZOQAah7sKcL/z1AkA8
#DeBB5U/OJVarnS6MInBZMLQzW2bSsCA9ffw3J9inzGcVWRVvtTAbZlyz/S4EoO8Q
#v8xizFxmGGeYn/HgY4HjAkEAxAJQPZ5X/0+Ips1kwVV9bqtdoVtXDLWpaM+LU1sf
#ZBj6w+FfJd5K+FeKSA1uJc2Jf1jc9qoKcMK/fOeP3jhvoQ==
#-----END RSA PRIVATE KEY-----
#',
#       encoding => 'BASE64',
#}
#netscaler_sslcertkey { 'test_sslcertkey':
#  ensure                => 'present',
#  certificate_filename  => '/nsconfig/server.cert',
#  certificate_format    => 'PEM',
#  key_filename          => '/nsconfig/server.key',
#  notify_when_expires   => 'ENABLED',
#}
#netscaler_lbvserver { 'lbvserver_ssl':
#        ensure       => 'present',
#        service_type => 'SSL',
#        ip_address   => '6.6.6.6',
#        port         => '8080',
#        state        => true,
#}
#netscaler_sslvserver_sslcertkey_binding { 'lbvserver_ssl/test_sslcertkey':
#  ensure => 'present',
#}
#    EOS
#    make_site_pp(pp)
#    run_device(:allow_changes => true)
#    run_device(:allow_changes => false)
#  end
#
#  it 'deletes a sslvserver_sslcertkey_binding' do
#    pp=<<-EOS
#netscaler_sslvserver_sslcertkey_binding { 'lbvserver_ssl/test_sslcertkey':
#  ensure => 'absent',
#}
#    EOS
#    make_site_pp(pp)
#    run_device(:allow_changes => true)
#    run_device(:allow_changes => false)
#  end
end
