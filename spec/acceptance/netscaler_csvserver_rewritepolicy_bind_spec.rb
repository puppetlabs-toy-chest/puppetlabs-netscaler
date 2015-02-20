require 'spec_helper_acceptance'

describe 'csvserver-rewritepolicy-binding' do
  it 'makes a csvserver-rewritepolicy-binding' do
    pp=<<-EOS
netscaler_rewritepolicy { '2_4_rewritepolicy_test1':
  ensure                  => 'present',
  action                  => 'NOREWRITE',
  comments                => 'comment',
  expression              => 'HTTP.REQ.URL.SUFFIX.EQ("")',
  undefined_result_action => 'DROP',
}

netscaler_csvserver { '2_4_csvserver_test1':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.4.1.1',
  port          => '8080',
}

netscaler_csvserver_rewritepolicy_bind { '2_4_csvserver_test1/2_4_rewritepolicy_test1':
  ensure               => present,
  priority             => 1,
  invoke_vserver_label => '2_4_csvserver_test1',
  choose_type          => 'Request',
}
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a csvserver-rewritepolicy-binding' do
    pp=<<-EOS
netscaler_rewritepolicy { '2_4_rewritepolicy_test2':
  ensure                  => 'present',
  action                  => 'NOREWRITE',
  comments                => 'comment',
  expression              => 'HTTP.REQ.URL.SUFFIX.EQ("")',
  undefined_result_action => 'DROP',
}

netscaler_csvserver { '2_4_csvserver_test2':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.4.2.1',
  port          => '8080',
}

netscaler_csvserver_rewritepolicy_bind { '2_4_csvserver_test2/2_4_rewritepolicy_test2':
  ensure               => present,
  priority             => 1,
  invoke_vserver_label => '2_4_csvserver_test2',
  choose_type          => 'Request',
}
EOS

    pp2=<<-EOS
netscaler_csvserver_rewritepolicy_bind { '2_4_csvserver_test2/2_4_rewritepolicy_test2':
  ensure    => absent,
}
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end