require 'spec_helper_acceptance'

describe 'rewritepolicy' do
  it 'makes a csvserver-rewritepolicy-binding' do
    pp=<<-EOS
netscaler_rewritepolicy { 'rewritepolicy_test1':
  ensure      => 'present',
  action      => 'NOREWRITE',
  comments    => 'comment',
  rule        => 'HTTP.REQ.URL.SUFFIX.EQ("")',
  undef_action => 'DROP',
}

netscaler_csvserver { 'csvserver_test1':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '9.9.9.9',
  port          => '8080',
}

netscaler_csvserver_rewritepolicy_bind { 'csvserver_test1/rewritepolicy_test1':
  ensure    => present,
  priority  => 1,
  bind_point => 'REQUEST',
}
EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a csvserver-rewritepolicy-binding' do
    pp=<<-EOS
netscaler_rewritepolicy { 'rewritepolicy_test2':
  ensure      => 'present',
  action      => 'NOREWRITE',
  comments    => 'comment',
  rule        => 'HTTP.REQ.URL.SUFFIX.EQ("")',
  undef_action => 'DROP',
}

netscaler_csvserver { 'csvserver_test2':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '9.9.9.10',
  port          => '8080',
}

netscaler_csvserver_rewritepolicy_bind { 'csvserver_test2/rewritepolicy_test2':
  ensure    => present,
  priority  => 1,
  bind_point => 'REQUEST',
}
EOS

    pp2=<<-EOS
netscaler_csvserver_rewritepolicy_bind { 'csvserver_test2/rewritepolicy_test2':
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