require 'spec_helper_acceptance'

#It is worth noting, even though the api documentation allows you to update a route, the ui or api will not let you
describe 'route' do
  it 'makes a route' do
    pp=<<-EOS
netscaler_route { '6.6.6.0/255.255.255.0:null':
  ensure   => 'present',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'deletes a route' do
    pp=<<-EOS
netscaler_route { '6.6.6.0/255.255.255.0:null':
  ensure   => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
  
  it 'add virtual ip & static route' do
    pp=<<-EOS
netscaler_route { '172.16.2.0/255.255.255.0:172.16.1.1':
  ensure    => 'present',
  advertise => 'ENABLED',
  msr       => 'ENABLED',
  protocol  => ['OSPF', 'ISIS', 'RIP', 'BGP'],
}
netscaler_nsip { '172.16.1.1':
  ensure                   => 'present',
  allow_management_access  => 'ENABLED',
  arp                      => 'ENABLED',
  arp_response             => 'ALL_VSERVERS',
  icmp                     => 'ENABLED',
  icmp_response            => 'ALL_VSERVERS',
  ip_type                  => 'VIP',
  netmask                  => '255.255.255.0',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
  
  it 'modify static route' do
    pp=<<-EOS
netscaler_route { '172.16.2.0/255.255.255.0:172.16.1.1':
  ensure    => 'present',
  advertise => 'DISABLED',
  msr       => 'DISABLED',
  protocol  => ['OSPF', 'BGP'],
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
  
  it 'delete static route & virtual ip' do
    pp=<<-EOS
netscaler_route { '172.16.2.0/255.255.255.0:172.16.1.1':
  ensure    => 'absent',
} ->
netscaler_nsip { '172.16.1.1':
  ensure    => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
