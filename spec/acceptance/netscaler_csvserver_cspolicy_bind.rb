require 'spec_helper_acceptance'

describe 'csvserver->cspolicy binding' do
  it 'makes a csvserver-cspolicy-binding' do
    pp=<<-EOS
netscaler_csvserver { '2_2_csvserver_test1':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.2.1.1',
  port          => '8080',
}

netscaler_lbvserver { '2_2_lbvserver_test1':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.2.1.2',
  port          => '8080',
}

netscaler_cspolicy { '2_2_cspolicy_test1':
  ensure => present,
  expression => 'HTTP.REQ.URL.PATH_AND_QUERY.CONTAINS("test")',
}

netscaler_csvserver_cspolicy_bind { '2_2_csvserver_test1/2_2_cspolicy_test1':
  ensure           => present,
  priority         => 1,
  target_lbvserver => '2_2_lbvserver_test1',
}
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

end