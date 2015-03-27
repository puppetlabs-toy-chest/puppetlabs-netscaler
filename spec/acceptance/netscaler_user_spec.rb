require 'spec_helper_acceptance'

describe 'user' do
  it 'makes a user' do
    pp=<<-EOS
netscaler_user { 'test_user':
  ensure                  => 'present',
  external_authentication => 'ENABLED',
  idle_time_out           => '900',
  logging_privilege       => 'ENABLED',
  password                => 'bla',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'edit a user' do
    pp=<<-EOS
netscaler_user { 'test_user':
  ensure                  => 'present',
  external_authentication => 'DISABLED',
  idle_time_out           => '1000',
  logging_privilege       => 'DISABLED',
  password                => 'changeme',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

 it 'delete a user' do
    pp=<<-EOS
netscaler_user { 'test_user':
  ensure => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
