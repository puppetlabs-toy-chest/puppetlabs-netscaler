require 'spec_helper_acceptance'

describe 'group' do
  it 'makes a group' do
    pp=<<-EOS
netscaler_group { 'test_group':
  ensure                  => 'present',
  idle_time_out           => '900',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'edit a group' do
    pp=<<-EOS
netscaler_group { 'test_group':
  ensure                  => 'present',
  idle_time_out           => '1000',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

 it 'delete a group' do
    pp=<<-EOS
netscaler_group { 'test_group':
  ensure => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
