require 'spec_helper_acceptance'

describe 'This is a demo of some netscaler functionality' do
  it 'running a complex manifest' do
    pp=<<-EOS
# basic netscaler config - user / group / usergroup / ntpserver / timezone / snmpalarm / hostname
netscaler_user { 'joe':
  ensure                  => 'present',
  external_authentication => 'ENABLED',
  idle_time_out           => '900',
  logging_privilege       => 'ENABLED',
  password                => 'bla',
}
netscaler_group { 'testing':
  ensure   => 'present',
}
netscaler_group_user_binding { 'testing/joe':
  ensure  => 'present',
}
netscaler_ntpserver { 'ntpservertest':
  ensure                => present,
  minimum_poll_interval => '5',
  maximum_poll_interval => '10',
  auto_key              => true,
  preferred_ntp_server  => 'yes',
}
netscaler_config { 'default':
  ensure   => present,
  timezone => 'GMT+01:00-CET-Europe/Andorra',
}
netscaler_snmpalarm { 'entity-state':
  severity         => 'critical',
  state            => true,
}
netscaler_nshostname { 'testname1': }

# enable a netscaler feature - community driven
netscaler_feature { 'Responder':
  ensure      => 'present',
}

# complex dependancies loadbalancing virtual server to a service
netscaler_server { '1_10_server1':
  ensure  => present,
  address => '1.10.1.1',
}
netscaler_service { '1_10_service1':
  ensure      => 'present',
  server_name => '1_10_server1',
  port        => '80',
  protocol    => 'HTTP',
  comments    => 'This is a comment'
}
netscaler_lbvserver { '1_10_lbvserver1':
  ensure       => 'present',
  service_type => 'HTTP',
  ip_address   => '1.10.1.2',
  port         => '8080',
  state        => true,
}
netscaler_lbvserver_service_binding { '1_10_lbvserver1/1_10_service1':
  ensure => 'present',
  weight => '100',
}

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
netscaler_csvserver_rewritepolicy_binding { '2_4_csvserver_test1/2_4_rewritepolicy_test1':
  ensure               => present,
  priority             => 1,
  invoke_vserver_label => '2_4_csvserver_test1',
  choose_type          => 'Request',
}

#simple repetition
netscaler_nsip { '3.1.1.1':
  ensure  => present,
  netmask => '255.255.255.0',
  ip_type => 'VIP',
}
netscaler_nsip { '3.1.2.1':
  ensure        => present,
  netmask       => '255.255.255.0',
  ip_type       => 'VIP',
  icmp_response => 'NONE',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

end
