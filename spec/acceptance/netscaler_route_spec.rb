require 'spec_helper_acceptance'

describe 'route' do
  it 'makes a route' do
    pp=<<-EOS
netscaler_route { '6.6.6.0/255.255.255.0:null':
  ensure   => 'present',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'deletes a route' do
    pp=<<-EOS
netscaler_route { '6.6.6.0/255.255.255.0:null':
  ensure   => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
