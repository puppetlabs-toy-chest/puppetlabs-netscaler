require 'spec_helper_acceptance'

describe 'nsip tests' do
  it 'makes an nsip' do
    pp=<<-EOS
      netscaler_nsip { '3.1.1.1':
        ensure  => present,
        netmask => '255.255.255.0',
        ip_type => 'VIP',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and edits an nsip' do
    pp=<<-EOS
      netscaler_nsip { '3.1.2.1':
        ensure  => present,
        netmask => '255.255.255.0',
        ip_type => 'VIP',
      }
    EOS

    pp2=<<-EOS
      netscaler_nsip { '3.1.2.1':
        ensure  => present,
        netmask => '255.255.0.0',
        ip_type => 'VIP',
      }
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes an nsip' do
    pp=<<-EOS
      netscaler_nsip { '3.1.3.1':
        ensure  => present,
        netmask => '255.255.255.0',
        ip_type => 'VIP',
      }
    EOS

    pp2=<<-EOS
      netscaler_nsip { '3.1.3.1':
        ensure  => absent,
      }
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and disables/enables an nsip' do
    pp=<<-EOS
      netscaler_nsip { '3.1.4.1':
        ensure  => present,
        netmask => '255.255.255.0',
        ip_type => 'VIP',
        state   => 'ENABLED',
      }
    EOS

    pp2=<<-EOS
      netscaler_nsip { '3.1.4.1':
        ensure  => present,
        netmask => '255.255.255.0',
        ip_type => 'VIP',
        state   => 'DISABLED',
      }
    EOS

    pp3=<<-EOS
      netscaler_nsip { '3.1.4.1':
        ensure  => present,
        netmask => '255.255.255.0',
        ip_type => 'VIP',
        state   => 'ENABLED',
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
