require 'spec_helper_acceptance'

describe 'sslcertkey' do
  #we need to upload a key and cert file, for this test to work

#  it 'makes a sslcertkey' do
#    pp=<<-EOS
#netscaler_sslcertkey { 'test_sslcertkey':
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
