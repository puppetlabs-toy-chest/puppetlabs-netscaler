require 'spec_helper_acceptance'

describe 'sslvserver' do
  #we need to upload a key and cert file, for this test to work

#  it 'makes a sslvserver' do
#    pp=<<-EOS
#netscaler_lbvserver { 'lbvserver_ssl':
#        ensure       => 'present',
#        service_type => 'SSL',
#        ip_address   => '6.6.6.6',
#        port         => '8080',
#        state        => true,
#}
#
#netscaler_sslcertkey { 'testing':
#  ensure               => 'present',
#  certificate_filename => 'server.crt',
#  certificate_format   => 'PEM',
#  key_filename         => 'server.key',
#  notify_when_expires  => 'ENABLED',
#}
#
#netscaler_sslvserver { 'test_sslvserver':
#  ensure                => 'present',
#  certificate_filename  => 'server.crt',
#  certificate_format    => 'PEM',
#  key_filename          => 'server.key',
#  notify_when_expires   => 'ENABLED',
#}
#    EOS
#    make_site_pp(pp)
#    run_device(:allow_changes => true)
#    run_device(:allow_changes => false)
#  end
end
