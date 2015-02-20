require 'spec_helper_acceptance'

describe 'service tests' do
  it 'makes a service' do
    pp=<<-EOS
      netscaler_server { 'server1':
        ensure  => present,
        address => '1.2.1.1',
      }

      netscaler_service { 'service1':
        ensure      => 'present',
        server_name => 'server1',
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
      netscaler_server { 'server2':
        ensure  => present,
        address => '1.2.2.1',
      }

      netscaler_service { 'service2':
        ensure      => 'present',
        server_name => 'server2',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is a comment'
      }
    EOS

    pp2=<<-EOS
      netscaler_service { 'service2':
        ensure      => 'present',
        server_name => 'server2',
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
      netscaler_server { 'server3':
        ensure  => present,
        address => '1.2.3.1',
      }

      netscaler_service { 'service3':
        ensure      => 'present',
        server_name => 'server3',
        port        => '80',
        protocol    => 'HTTP',
        comments    => 'This is a comment'
      }
    EOS

    pp2=<<-EOS
      netscaler_service { 'service3':
        ensure      => 'absent',
      }
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

end
