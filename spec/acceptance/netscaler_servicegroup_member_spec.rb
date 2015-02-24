require 'spec_helper_acceptance'

describe 'servicegroup_member tests' do
  it 'makes a servicegroup_member' do
    pp=<<-EOS
      netscaler_server { '1_6_server1':
        ensure  => present,
        address => '1.6.1.1',
      }

      netscaler_servicegroup { '1_6_servicegroup1':
        ensure            => 'present',
        member_port       => '80',
        autoscale_mode    => 'POLICY',
        protocol          => 'HTTP',
        maximum_bandwidth => '1024',
        comments          => 'This is a comment'
      }

      netscaler_servicegroup_member { '1_6_servicegroup1/1_6_server1:80':
        ensure => 'present',
        weight => '1',
        state  => 'ENABLED',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a servicegroup_member' do
    pp=<<-EOS
      netscaler_server { '1_6_server2':
        ensure  => present,
        address => '1.6.2.1',
      }

      netscaler_servicegroup { '1_6_servicegroup2':
        ensure            => 'present',
        member_port       => '80',
        autoscale_mode    => 'POLICY',
        protocol          => 'HTTP',
        maximum_bandwidth => '1024',
        comments          => 'This is a comment'
      }

      netscaler_servicegroup_member { '1_6_servicegroup2/1_6_server2:80':
        ensure => 'present',
        weight => '1',
        state  => 'ENABLED',
      }
    EOS

    pp2=<<-EOS
      netscaler_servicegroup_member { '1_6_servicegroup2/1_6_server2:80':
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
