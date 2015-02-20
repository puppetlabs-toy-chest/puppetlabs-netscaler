require 'spec_helper_acceptance'

describe 'rewriteglobal' do
  it 'makes a rewriteglobal (reqvserver)' do
    pp=<<-EOS
netscaler_lbvserver { '2_12_lbvirtualserver1':
  ensure       => 'present',
  ip_address   => '2.12.1.1',
  port         => '80',
  service_type => 'HTTP',
  state        => 'ENABLED',
}

netscaler_rewritepolicy { '2_12_rewritepolicy_test1':
  ensure                  => 'present',
  action                  => 'NOREWRITE',
  comments                => 'comment',
  expression              => 'HTTP.REQ.URL.SUFFIX.EQ("")',
  undefined_result_action => 'DROP',
}

netscaler_rewriteglobal {'2_12_rewritepolicy_test1':
  ensure               => 'present',
  priority             => '100',
  goto_expression      => 'END',
  invoke_vserver_label => '2_12_lbvirtualserver1',
  connection_type      => 'Request',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

 it 'delete a rewriteglobal (reqvserver)' do
    pp=<<-EOS
netscaler_lbvserver { '2_12_lbvirtualserver2':
  ensure       => 'present',
  ip_address   => '2.12.2.1',
  port         => '80',
  service_type => 'HTTP',
  state        => 'ENABLED',
}

netscaler_rewritepolicy { '2_12_rewritepolicy_test2':
  ensure                  => 'present',
  action                  => 'NOREWRITE',
  comments                => 'comment',
  expression              => 'HTTP.REQ.URL.SUFFIX.EQ("")',
  undefined_result_action => 'DROP',
}

netscaler_rewriteglobal {'2_12_rewritepolicy_test2':
  ensure               => 'present',
  priority             => '101',
  goto_expression      => 'END',
  invoke_vserver_label => '2_12_lbvirtualserver2',
  connection_type      => 'Request',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)

    pp2=<<-EOS
netscaler_rewriteglobal { '2_12_rewritepolicy_test2':
  ensure            => 'absent',
}
    EOS
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes a rewriteglobal (resvserver)' do
    pp=<<-EOS
netscaler_lbvserver { '2_12_lbvirtualserver3':
  ensure       => 'present',
  ip_address   => '2.12.3.1',
  port         => '80',
  service_type => 'HTTP',
  state        => 'ENABLED',
}

netscaler_rewritepolicy { '2_12_rewritepolicy_test3':
  ensure                  => 'present',
  action                  => 'NOREWRITE',
  comments                => 'comment',
  expression              => 'HTTP.RES.HEADER("test").CONTAINS("test")',
  undefined_result_action => 'DROP',
}

netscaler_rewriteglobal {'2_12_rewritepolicy_test3':
  ensure               => 'present',
  priority             => '102',
  goto_expression      => 'END',
  invoke_vserver_label => '2_12_lbvirtualserver3',
  connection_type      => 'Response',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes a rewriteglobal (no invoke)' do
    pp=<<-EOS
netscaler_rewritepolicy { '2_12_rewritepolicy_test4':
  ensure                  => 'present',
  action                  => 'NOREWRITE',
  comments                => 'comment',
  expression              => 'HTTP.RES.HEADER("test").CONTAINS("test")',
  undefined_result_action => 'DROP',
}

netscaler_rewriteglobal {'2_12_rewritepolicy_test4':
  ensure               => 'present',
  priority             => '103',
  goto_expression      => 'END',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

end
