require 'spec_helper_acceptance'

describe 'service tests' do
  it 'makes a service' do
    pp=<<-EOS
      netscaler_server { '1_2_server1':
        ensure  => present,
        address => '1.2.1.1',
      }

      netscaler_service { '1_2_service1':
        ensure      => 'present',
        server_name => '1_2_server1',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is a comment'
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and edits a service' do
    pp=<<-EOS
      netscaler_server { '1_2_server2':
        ensure  => present,
        address => '1.2.2.1',
      }

      netscaler_service { '1_2_service2':
        ensure      => 'present',
        server_name => '1_2_server2',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is a comment'
      }
    EOS

    pp2=<<-EOS
      netscaler_service { '1_2_service2':
        ensure      => 'present',
        server_name => '1_2_server2',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is an even better, updated comment'
      }
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a service' do
    pp=<<-EOS
      netscaler_server { '1_2_server3':
        ensure  => present,
        address => '1.2.3.1',
      }

      netscaler_service { '1_2_service3':
        ensure      => 'present',
        server_name => '1_2_server3',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is a comment'
      }
    EOS

    pp2=<<-EOS
      netscaler_service { '1_2_service3':
        ensure      => 'absent',
      }
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and disables/enables a service' do
    pp=<<-EOS
      netscaler_server { '1_2_server4':
        ensure  => present,
        address => '1.2.4.1',
      }

      netscaler_service { '1_2_service4':
        ensure      => 'present',
        server_name => '1_2_server4',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is a comment',
        state       => 'ENABLED'
      }
    EOS

    pp2=<<-EOS
      netscaler_service { '1_2_service4':
        ensure      => 'present',
        server_name => '1_2_server4',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is a comment',
        state       => 'DISABLED'
      }
    EOS

    pp3=<<-EOS
      netscaler_service { '1_2_service4':
        ensure      => 'present',
        server_name => '1_2_server4',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is a comment',
        state       => 'ENABLED'
      }
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
    make_site_pp(pp3)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
