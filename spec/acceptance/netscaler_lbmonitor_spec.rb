require 'spec_helper_acceptance'

describe 'lbmonitor tests' do
  it 'makes a lbmonitor' do
    pp=<<-EOS
      netscaler_lbmonitor { '1_7_lbmonitor1':
        ensure            => 'present',
        type              => 'HTTP',
        destination_ip    => '1.7.1.1',
        destination_port  => '80',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and edits a lbmonitor' do
    pp=<<-EOS
      netscaler_lbmonitor { '1_7_lbmonitor2':
        ensure            => 'present',
        type              => 'HTTP',
        destination_ip    => '1.7.2.1',
        destination_port  => '80',
      }
    EOS

    pp2=<<-EOS
      netscaler_lbmonitor { '1_7_lbmonitor2':
        ensure            => 'present',
        type              => 'HTTP',
        destination_ip    => '1.7.2.2',
        destination_port  => '8080',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a lbmonitor' do
    pp=<<-EOS
      netscaler_lbmonitor { '1_7_lbmonitor3':
        ensure            => 'present',
        type              => 'HTTP',
        destination_ip    => '1.7.3.1',
        destination_port  => '80',
      }
    EOS

    pp2=<<-EOS
      netscaler_lbmonitor { '1_7_lbmonitor3':
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
