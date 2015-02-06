require 'spec_helper_acceptance'

describe 'csvserver tests' do
  it 'makes a csvserver' do
    pp=<<-EOS
    netscaler_csvserver { 'csvserver1':
      ensure        => 'present',
      service_type  => 'DNS',
      state         => true,
      ip_address    => '9.9.9.9',
      port          => '8080',
    }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and edits a csvserver' do
    pp=<<-EOS
    netscaler_csvserver { 'csvserver2':
      ensure       => 'present',
      service_type => 'HTTP',
      ip_address   => '8.8.8.8',
      port         => '8080',
      state        => true,
    }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)

    pp=<<-EOS
    netscaler_csvserver { 'csvserver2':
      ensure       => 'present',
      service_type => 'HTTP',
      ip_address   => '8.8.8.9',
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
    netscaler_csvserver { 'csvserver3':
      ensure       => 'present',
      service_type => 'HTTP',
      ip_address   => '8.8.8.10',
      port         => '8080',
      state        => true,
    }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)

    pp=<<-EOS
    netscaler_csvserver { 'csvserver3':
      ensure  => 'absent',
    }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

end
