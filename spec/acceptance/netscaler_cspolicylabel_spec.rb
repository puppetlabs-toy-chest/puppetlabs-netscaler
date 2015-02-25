require 'spec_helper_acceptance'

describe 'cspolicylabel' do
  it 'makes a cspolicylabel' do
    pp=<<-EOS
netscaler_cspolicylabel { 'test':
  ensure      => present,
  label_type  => 'HTTP',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'delete a cspolicylabel' do
    pp=<<-EOS
netscaler_cspolicylabel { 'test':
  ensure => absent,
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
