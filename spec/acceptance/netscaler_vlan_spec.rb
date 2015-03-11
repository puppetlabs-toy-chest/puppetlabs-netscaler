require 'spec_helper_acceptance'

describe 'vlan tests' do
  it 'makes a vlan' do
    pp=<<-EOS
      netscaler_vlan { '11':
        ensure                    => present,
        alias_name                => 'test alias',
        ipv6_dynamic_routing      => 'VIP',
        maximum_transmission_unit => '1111',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and edits a vlan' do
    pp=<<-EOS
      netscaler_vlan { '12':
        ensure                    => present,
        alias_name                => 'test alias',
        ipv6_dynamic_routing      => 'VIP',
        maximum_transmission_unit => '2222',
      }
    EOS

    pp2=<<-EOS
      netscaler_vlan { '12':
        ensure                    => present,
        alias_name                => 'test alias',
        ipv6_dynamic_routing      => 'VIP',
        maximum_transmission_unit => '2223',
      }
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a vlan' do
    pp=<<-EOS
      netscaler_vlan { '13':
        ensure                    => present,
        alias_name                => 'test alias',
        ipv6_dynamic_routing      => 'VIP',
        maximum_transmission_unit => '3333',
      }
    EOS

    pp2=<<-EOS
      netscaler_vlan { '13':
        ensure  => absent,
      }
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
