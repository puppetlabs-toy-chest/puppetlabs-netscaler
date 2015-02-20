require 'spec_helper_acceptance'

describe 'server tests' do
  it 'makes a server' do
    pp=<<-EOS
      netscaler_server { 'server1':
        ensure  => present,
        address => '1.1.1.1',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and edits a server' do
    pp=<<-EOS
      netscaler_server { 'server2':
        ensure  => present,
        address => '1.1.2.1',
      }
    EOS

    pp2=<<-EOS
      netscaler_server { 'server2':
        ensure  => present,
        address => '1.1.2.2',
      }
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a server' do
    pp=<<-EOS
      netscaler_server { 'server3':
        ensure  => present,
        address => '1.1.3.1',
      }
    EOS

    pp2=<<-EOS
      netscaler_server { 'server3':
        ensure  => absent,
      }
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes a server (using a domain)' do
    pp=<<-EOS
      netscaler_server { 'server4':
        ensure  => present,
        address => 'www.example.org',
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

end
