require 'spec_helper_acceptance'

describe 'vlan_nsip_binding tests' do
  it 'binds a vlan_nsip_binding' do
    pp=<<-EOS
      netscaler_vlan { '3311':
        ensure  => 'present',
      }
      netscaler_nsip { '3.3.1.1':
        ensure  => present,
        netmask => '255.255.255.0',
      }
      netscaler_vlan_nsip_binding { '3311/3.3.1.1':
        ensure  => 'present',
        netmask => '255.255.255.0',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a service_lbmonitor_binding' do
    pp=<<-EOS
      netscaler_vlan { '3321':
        ensure  => 'present',
      }
      netscaler_nsip { '3.3.2.1':
        ensure  => present,
        netmask => '255.255.255.0',
      }
      netscaler_vlan_nsip_binding { '3321/3.3.2.1':
        ensure  => 'present',
        netmask => '255.255.255.0',
      }
    EOS

    pp2=<<-EOS
      netscaler_vlan_nsip_binding { '3321/3.3.2.1':
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
