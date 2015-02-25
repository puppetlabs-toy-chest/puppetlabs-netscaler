require 'spec_helper_acceptance'

describe 'sslcertfile' do
  it 'makes a sslcertfile' do
    pp=<<-EOS
netscaler_sslcertfile { 'monkey':
  ensure      => 'present',
  source      => 'https://www.geotrust.com/uk/resources/root_certificates/certificates/GeoTrust_Primary_CA.pem',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
