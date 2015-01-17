require 'spec_helper_acceptance'

describe 'something' do
  it 'makes a node' do
    pp=<<-EOS
    netscaler_server { 'aoeu4':
      ensure  => 'present',
      address => '::44',
      state   => true,
    }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
