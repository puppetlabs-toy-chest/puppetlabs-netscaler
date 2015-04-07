require 'spec_helper_acceptance'

describe 'lbvserver_service_binding tests' do
  it 'makes a lbvserver_service_binding' do
    pp=<<-EOS
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
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a lbvserver_service_binding' do
    pp=<<-EOS
      netscaler_server { '1_10_server2':
        ensure  => present,
        address => '1.10.2.1',
      }

      netscaler_service { '1_10_service2':
        ensure      => 'present',
        server_name => '1_10_server2',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is a comment'
      }

      netscaler_lbvserver { '1_10_lbvserver2':
        ensure       => 'present',
        service_type => 'HTTP',
        ip_address   => '1.10.2.2',
        port         => '8080',
        state        => true,
      }

      netscaler_lbvserver_service_binding { '1_10_lbvserver2/1_10_service2':
        ensure => 'present',
        weight => '100',
      }
    EOS

    pp2=<<-EOS
      netscaler_lbvserver_service_binding { '1_10_lbvserver2/1_10_service2':
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
