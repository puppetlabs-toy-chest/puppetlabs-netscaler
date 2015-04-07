require 'spec_helper_acceptance'

describe 'csvserver-lbvserver-binding' do
  it 'add a csvserver and a lbvserver then bind the two' do
    pp=<<-EOS
netscaler_csvserver { '2_17_csvserver_test1':
  ensure            => 'present',
  service_type      => 'HTTP',
  state             => true,
  ip_address        => '2.17.1.1',
  port              => '8080',
  default_lbvserver => '2_17_lbvserver_test1',
}

netscaler_lbvserver { '2_17_lbvserver_test1':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.17.1.2',
  port          => '8080',
}
netscaler_csvserver_lbvserver_binding { '2_17_csvserver_test1/2_17_lbvserver_test1':
  ensure         => 'present',
}
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'deletes csvserver-lbvserver-binding' do
    pp=<<-EOS
netscaler_csvserver_lbvserver_binding { '2_17_csvserver_test1/2_17_lbvserver_test1':
  ensure        => 'absent',
}
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
