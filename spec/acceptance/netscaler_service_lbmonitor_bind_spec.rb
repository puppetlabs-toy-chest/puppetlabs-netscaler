require 'spec_helper_acceptance'

describe 'service_lbmonitor_bind tests' do
  it 'makes a service_lbmonitor_bind' do
    pp=<<-EOS
      netscaler_lbmonitor { '1_3_lbmonitor1':
        ensure            => 'present',
        type              => 'LOAD',
        destination_ip    => '1.3.1.1',
        destination_port  => '80',
      }

      netscaler_server { '1_3_server1':
        ensure  => present,
        address => '1.3.1.2',
      }

      netscaler_service { '1_3_service1':
        ensure      => 'present',
        server_name => '1_3_server1',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is a comment'
      }

      netscaler_service_lbmonitor_bind { '1_3_service1/1_3_lbmonitor1':
        ensure  => 'present',
        weight  => '100',
        state   => 'ENABLED',
        #passive => 'true',
      }

    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a service_lbmonitor_bind' do
    pp=<<-EOS
      netscaler_lbmonitor { '1_3_lbmonitor2':
        ensure            => 'present',
        type              => 'LOAD',
        destination_ip    => '1.3.2.1',
        destination_port  => '80',
      }

      netscaler_server { '1_3_server2':
        ensure  => present,
        address => '1.3.2.2',
      }

      netscaler_service { '1_3_service2':
        ensure      => 'present',
        server_name => '1_3_server2',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is a comment'
      }

      netscaler_service_lbmonitor_bind { '1_3_service2/1_3_lbmonitor2':
        ensure  => 'present',
        weight  => '100',
        state   => 'ENABLED',
        #passive => 'true',
      }

    EOS

    pp2=<<-EOS
      netscaler_service_lbmonitor_bind { '1_3_service2/1_3_lbmonitor2':
        ensure  => 'absent',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
