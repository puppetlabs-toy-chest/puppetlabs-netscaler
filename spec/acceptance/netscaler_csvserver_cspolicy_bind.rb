require 'spec_helper_acceptance'

describe 'csvserver->cspolicy binding' do
  it 'makes a csvserver-cspolicy-binding' do
    pp=<<-EOS
netscaler_csvserver { 'csvserver_test1':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '9.9.9.9',
  port          => '8080',
}

netscaler_lbvserver { 'lbvserver_test1':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '10.9.9.9',
  port          => '8080',
}

netscaler_cspolicy { 'cspolicy_test1':
  ensure => present,
  expression => 'HTTP.REQ.URL.PATH_AND_QUERY.CONTAINS("test")',
}

netscaler_csvserver_cspolicy_bind { 'csvserver_test1/cspolicy_test1':
  ensure           => present,
  priority         => 1,
  target_lbvserver => 'lbvserver_test1',
}
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

end