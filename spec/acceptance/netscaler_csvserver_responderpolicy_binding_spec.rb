require 'spec_helper_acceptance'

describe 'responderpolicy' do
  it 'makes a csvserver-responderpolicy-binding (no invoke)' do
    pp=<<-EOS
netscaler_responderpolicy { '2_3_responderpolicy_test1':
  ensure                  => 'present',
  action                  => 'NOOP',
  comments                => 'comment',
  expression              => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
  undefined_result_action => 'NOOP',
}

netscaler_csvserver { '2_3_csvserver_test1':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.3.1.1',
  port          => '8080',
}

netscaler_csvserver_responderpolicy_binding { '2_3_csvserver_test1/2_3_responderpolicy_test1':
  ensure    => present,
  priority  => 1,
}
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a csvserver-responderpolicy-binding (no invoke)' do
    pp=<<-EOS
netscaler_responderpolicy { '2_3_responderpolicy_test2':
  ensure                  => 'present',
  action                  => 'NOOP',
  comments                => 'comment',
  expression              => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
  undefined_result_action => 'NOOP',
}

netscaler_csvserver { '2_3_csvserver_test2':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.3.2.1',
  port          => '8080',
}

netscaler_csvserver_responderpolicy_binding { '2_3_csvserver_test2/2_3_responderpolicy_test2':
  ensure    => present,
  priority  => 1,
}
EOS

    pp2=<<-EOS
netscaler_csvserver_responderpolicy_binding { '2_3_csvserver_test2/2_3_responderpolicy_test2':
  ensure    => absent,
}
EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes a csvserver-responderpolicy-binding (resvserver)' do
    pp=<<-EOS
netscaler_responderpolicy { '2_3_responderpolicy_test3':
  ensure                  => 'present',
  action                  => 'NOOP',
  comments                => 'comment',
  expression              => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
  undefined_result_action => 'NOOP',
}

netscaler_csvserver { '2_3_csvserver_test3':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.3.3.1',
  port          => '8080',
}

netscaler_lbvserver { '2_3_lbvserver_test3':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.3.3.2',
  port          => '8080',
}

netscaler_csvserver_responderpolicy_binding { '2_3_csvserver_test3/2_3_responderpolicy_test3':
  ensure               => present,
  priority             => 1,
  invoke_vserver_label => '2_3_lbvserver_test3',
}
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
