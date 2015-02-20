require 'spec_helper_acceptance'

describe 'csvserver-lbvserver-binding' do
  it 'makes a csvserver-lbvserver-binding' do
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
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and edits a csvserver-lbvserver-binding' do
    pp=<<-EOS
netscaler_csvserver { '2_17_csvserver_test2':
  ensure            => 'present',
  service_type      => 'HTTP',
  state             => true,
  ip_address        => '2.17.2.1',
  port              => '8080',
  default_lbvserver => '2_17_lbvserver_test2_1',
}

netscaler_lbvserver { '2_17_lbvserver_test2_1':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.17.2.2',
  port          => '8080',
}
EOS

    pp2=<<-EOS
netscaler_csvserver { '2_17_csvserver_test2':
  ensure            => 'present',
  service_type      => 'HTTP',
  state             => true,
  ip_address        => '2.17.2.1',
  port              => '8080',
  default_lbvserver => '2_17_lbvserver_test2_2',
}

netscaler_lbvserver { '2_17_lbvserver_test2_2':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.17.2.3',
  port          => '8080',
}
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end