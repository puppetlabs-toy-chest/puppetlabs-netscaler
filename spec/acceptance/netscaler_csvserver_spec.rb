require 'spec_helper_acceptance'

describe 'csvserver tests' do
  it 'makes a csvserver' do
    pp=<<-EOS
    netscaler_csvserver { '2_1_csvserver1':
      ensure       => 'present',
      service_type => 'DNS',
      state        => true,
      ip_address   => '2.1.1.1',
      port         => '8080',
    }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and edits a csvserver' do
    pp=<<-EOS
    netscaler_csvserver { '2_1_csvserver2':
      ensure       => 'present',
      service_type => 'HTTP',
      ip_address   => '2.1.2.1',
      port         => '8080',
      state        => true,
    }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)

    pp=<<-EOS
    netscaler_csvserver { '2_1_csvserver2':
      ensure       => 'present',
      service_type => 'HTTP',
      ip_address   => '2.1.2.2',
      port         => '8080',
      state        => true,
    }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a csvserver' do
    pp=<<-EOS
    netscaler_csvserver { '2_1_csvserver3':
      ensure       => 'present',
      service_type => 'HTTP',
      ip_address   => '2.1.3.1',
      port         => '8080',
      state        => true,
    }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)

    pp=<<-EOS
    netscaler_csvserver { '2_1_csvserver3':
      ensure => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and disables/enables a csvserver' do
    pp=<<-EOS
    netscaler_csvserver { '2_1_csvserver4':
      ensure       => 'present',
      service_type => 'HTTP',
      ip_address   => '2.1.4.1',
      port         => '8080',
      state        => 'ENABLED',
    }
    EOS

    pp2=<<-EOS
    netscaler_csvserver { '2_1_csvserver4':
      ensure       => 'present',
      service_type => 'HTTP',
      ip_address   => '2.1.4.1',
      port         => '8080',
      state        => 'DISABLED',
    }
    EOS

    pp3=<<-EOS
    netscaler_csvserver { '2_1_csvserver4':
      ensure       => 'present',
      service_type => 'HTTP',
      ip_address   => '2.1.4.1',
      port         => '8080',
      state        => 'ENABLED',
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
