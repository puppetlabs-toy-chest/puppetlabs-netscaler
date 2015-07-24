require 'spec_helper_acceptance'

describe 'sslcertfile' do
  it 'makes a sslcertfile' do
    pp=<<-EOS
netscaler_sslcertfile { 'monkey':
  ensure      => 'present',
  source      => 'https://www.geotrust.com/resources/root_certificates/certificates/GeoTrust_Global_CA.pem',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'deletes a sslcertfile' do
    pp=<<-EOS
netscaler_sslcertfile { 'monkey':
  ensure      => 'absent',
  source      => 'https://www.geotrust.com/resources/root_certificates/certificates/GeoTrust_Global_CA.pem',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
