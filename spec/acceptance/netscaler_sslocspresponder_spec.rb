require 'spec_helper_acceptance'

describe 'sslocspresponder' do

  it 'makes a sslocspresponder' do
    pp=<<-EOS
netscaler_sslocspresponder { 'test_sslocspresponder':
  ensure                => 'present',
  url  => 'http://www.bla.com',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
