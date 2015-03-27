require 'spec_helper_acceptance'

describe 'responderglobal' do
  it 'makes a responderglobal' do
    pp=<<-EOS
netscaler_lbvserver { 'lbvirtualserver1':
  ensure                           => 'present',
  ip_address                       => '2.8.1.1',
  port                             => '80',
  service_type                     => 'HTTP',
  state                            => 'ENABLED',
}
netscaler_responderglobal {'Top_URL_CLIENTS_CSVSERVER':
  ensure               => 'present',
  priority             => '100',
  goto_expression      => 'END',
  invoke_vserver_label => 'lbvirtualserver1',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

 it 'delete a responderglobal' do
    pp=<<-EOS
netscaler_lbvserver { 'lbvirtualserver1':
  ensure       => 'present',
  ip_address   => '2.8.3.1',
  port         => '80',
  service_type => 'HTTP',
  state        => 'ENABLED',
}
netscaler_responderglobal {'Top_URL_CLIENTS_CSVSERVER':
  ensure               => 'present',
  priority             => '100',
  goto_expression      => 'END',
  invoke_vserver_label => 'lbvirtualserver1',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)

    pp2=<<-EOS
netscaler_responderglobal { 'Top_URL_CLIENTS_CSVSERVER':
  ensure => 'absent',
}
    EOS
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
