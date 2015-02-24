require 'spec_helper_acceptance'

describe 'servicegroup_lbmonitor_bind tests' do
  it 'makes a servicegroup_lbmonitor_bind' do
    pp=<<-EOS
      netscaler_lbmonitor { '1_5_lbmonitor1':
        ensure            => 'present',
        type              => 'LOAD',
        destination_ip    => '1.5.1.1',
        destination_port  => '80',
      }

      netscaler_servicegroup { '1_5_servicegroup1':
        ensure            => 'present',
        member_port       => '80',
        autoscale_mode    => 'POLICY',
        protocol          => 'HTTP',
        maximum_bandwidth => '1024',
        comments          => 'This is a comment'
      }

      netscaler_servicegroup_lbmonitor_bind { '1_5_servicegroup1/1_5_lbmonitor1':
        ensure  => 'present',
        weight  => '100',
        state   => 'ENABLED',
        passive => 'true',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and destroys a servicegroup_lbmonitor_bind' do
    pp=<<-EOS
      netscaler_lbmonitor { '1_5_lbmonitor2':
        ensure            => 'present',
        type              => 'LOAD',
        destination_ip    => '1.5.2.1',
        destination_port  => '80',
      }

      netscaler_servicegroup { '1_5_servicegroup2':
        ensure            => 'present',
        member_port       => '80',
        autoscale_mode    => 'POLICY',
        protocol          => 'HTTP',
        maximum_bandwidth => '1024',
        comments          => 'This is a comment'
      }

      netscaler_servicegroup_lbmonitor_bind { '1_5_servicegroup2/1_5_lbmonitor2':
        ensure  => 'present',
        weight  => '100',
        state   => 'ENABLED',
        passive => 'true',
      }
    EOS

    pp2=<<-EOS
      netscaler_servicegroup_lbmonitor_bind { '1_5_servicegroup2/1_5_lbmonitor2':
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
