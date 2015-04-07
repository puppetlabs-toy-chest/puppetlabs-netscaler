require 'spec_helper_acceptance'

describe 'creates a typical netscaler deployment' do
  it 'makes a server / service / bindings / monitor' do
    pp=<<-EOS
node 'netscaler' {
# Declare first server+service+monitor
  netscaler_server { 'server-1': # 5 clicks
  ensure  => present,
  address => '10.109.29.5',
}
netscaler_service { 'service-http-1': # 7 clicks
  ensure      => 'present',
  server_name => 'server-1',
  port        => '80',
  protocol    => 'HTTP',
}
netscaler_service_lbmonitor_binding { 'service-http-1/http': # 10 clicks
  ensure => present,
}

# Declare second server+service+monitor
netscaler_server { 'server-2': # 5 clicks
  ensure  => present,
  address => '10.109.29.6',
}
netscaler_service { 'service-http-2': # 7 clicks
  ensure      => 'present',
  server_name => 'server-2',
  port        => '80',
  protocol    => 'HTTP',
}
netscaler_service_lbmonitor_binding { 'service-http-2/http': # 10 clicks
  ensure => present,
}

# Declare loadbalancing vserver
netscaler_lbvserver { 'vserver-lb-1': # 6 clicks
  ensure        => present,
  ip_address    => '10.102.29.60',
  port          => '80',
  service_type  => 'HTTP',
}
netscaler_lbvserver_service_binding { 'vserver-lb-1/service-http-1': # 5 clicks
  ensure => 'present',
}
netscaler_lbvserver_service_binding { 'vserver-lb-1/service-http-2': # 5 clicks
  ensure => 'present',
}

# Total of ~60 clicks and 13 text fields
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
