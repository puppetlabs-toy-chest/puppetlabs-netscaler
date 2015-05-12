require 'spec_helper_acceptance'

describe 'lbvserver_servicegroup_binding tests' do
  it 'makes a lbvserver_servicegroup_binding' do
    pp=<<-EOS
      netscaler_server { '1_10_server1':
        ensure  => present,
        address => '1.10.1.1',
      }

      netscaler_servicegroup { '1_10_servicegroup1':
        ensure   => 'present',
        protocol => 'HTTP',
      }
      

      netscaler_lbvserver { '1_10_lbvserver1':
        ensure       => 'present',
        service_type => 'HTTP',
        ip_address   => '1.10.1.2',
        port         => '8080',
        state        => true,
      }

      netscaler_lbvserver_servicegroup_binding { "1_10_lbvserver1/1_10_servicegroup1": 
        ensure => present,
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a lbvserver_servicegroup_binding' do
    pp=<<-EOS
      netscaler_server { '1_10_server1':
        ensure  => present,
        address => '1.10.1.1',
      }

      netscaler_servicegroup { '1_10_servicegroup1':
        ensure   => 'present',
        protocol => 'HTTP',
      }

      netscaler_lbvserver { '1_10_lbvserver1':
        ensure       => 'present',
        service_type => 'HTTP',
        ip_address   => '1.10.1.2',
        port         => '8080',
        state        => true,
      }

      netscaler_lbvserver_servicegroup_binding { '1_10_lbvserver1/1_10_servicegroup1':
        ensure => present,
      }
    EOS

    pp2=<<-EOS
      netscaler_lbvserver_servicegroup_binding { '1_10_lbvserver1/1_10_servicegroup1':
        ensure => 'absent',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
