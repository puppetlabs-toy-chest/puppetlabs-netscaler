require 'spec_helper_acceptance'

describe 'servicegroup tests' do
  it 'makes a servicegroup' do
    pp=<<-EOS
      netscaler_servicegroup { '1_4_servicegroup':
        ensure            => 'present',
        member_port       => '80',
        autoscale_mode    => 'POLICY',
        protocol          => 'HTTP',
        maximum_bandwidth => '1024',
        comments          => 'This is a comment'
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and edits servicegroup' do
    pp=<<-EOS
      netscaler_servicegroup { '1_4_servicegroup2':
        ensure            => 'present',
        member_port       => '80',
        autoscale_mode    => 'POLICY',
        protocol          => 'HTTP',
        maximum_bandwidth => '1024',
        comments          => 'This is a comment'
      }
    EOS

    pp2=<<-EOS
      netscaler_servicegroup { '1_4_servicegroup2':
        ensure            => 'present',
        member_port       => '80',
        autoscale_mode    => 'POLICY',
        protocol          => 'HTTP',
        maximum_bandwidth => '2048',
        comments          => 'This is a comment'
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes servicegroup' do
    pp=<<-EOS
      netscaler_servicegroup { '1_4_servicegroup3':
        ensure            => 'present',
        member_port       => '80',
        autoscale_mode    => 'POLICY',
        protocol          => 'HTTP',
        maximum_bandwidth => '1024',
        comments          => 'This is a comment'
      }
    EOS

    pp2=<<-EOS
      netscaler_servicegroup { '1_4_servicegroup3':
        ensure            => 'absent',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
