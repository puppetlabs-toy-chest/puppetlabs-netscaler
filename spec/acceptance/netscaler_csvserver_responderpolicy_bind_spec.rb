require 'spec_helper_acceptance'

describe 'responderpolicy' do
  it 'makes a csvserver-responderpolicy-binding' do
    pp=<<-EOS
netscaler_responderpolicy { 'responderpolicy_test1':
  ensure      => 'present',
  action      => 'NOOP',
  comments    => 'comment',
  rule        => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
  undefaction => 'NOOP',
}

netscaler_csvserver { 'csvserver_test1':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '9.9.9.9',
  port          => '8080',
}

netscaler_csvserver_responderpolicy_bind { 'csvserver_test1/responderpolicy_test1':
  ensure    => present,
  priority  => 1,
}
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a csvserver-responderpolicy-binding' do
    pp=<<-EOS
netscaler_responderpolicy { 'responderpolicy_test2':
  ensure      => 'present',
  action      => 'NOOP',
  comments    => 'comment',
  rule        => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
  undefaction => 'NOOP',
}

netscaler_csvserver { 'csvserver_test2':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '9.9.9.10',
  port          => '8080',
}

netscaler_csvserver_responderpolicy_bind { 'csvserver_test2/responderpolicy_test2':
  ensure    => present,
  priority  => 1,
}
EOS

    pp2=<<-EOS
netscaler_csvserver_responderpolicy_bind { 'csvserver_test2/responderpolicy_test2':
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
