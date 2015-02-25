require 'spec_helper_acceptance'

describe 'lbvserver-responderpolicy-binding' do
  it 'makes a lbvserver-responderpolicy-binding (no invoke)' do
    pp=<<-EOS
      netscaler_responderpolicy { '1_9_responderpolicy_test1':
        ensure                  => 'present',
        action                  => 'NOOP',
        comments                => 'comment',
        expression              => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
        undefined_result_action => 'NOOP',
      }

      netscaler_lbvserver { '1_9_lbvserver_test1':
        ensure        => 'present',
        service_type  => 'HTTP',
        state         => true,
        ip_address    => '1.9.1.1',
        port          => '8080',
      }

      netscaler_lbvserver_responderpolicy_bind { '1_9_lbvserver_test1/1_9_responderpolicy_test1':
        ensure    => present,
        priority  => 1,
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a lbvserver-responderpolicy-binding (no invoke)' do
    pp=<<-EOS
      netscaler_responderpolicy { '1_9_responderpolicy_test2':
        ensure                  => 'present',
        action                  => 'NOOP',
        comments                => 'comment',
        expression              => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
        undefined_result_action => 'NOOP',
      }

      netscaler_lbvserver { '1_9_lbvserver_test2':
        ensure        => 'present',
        service_type  => 'HTTP',
        state         => true,
        ip_address    => '1.9.2.1',
        port          => '8080',
      }

      netscaler_lbvserver_responderpolicy_bind { '1_9_lbvserver_test2/1_9_responderpolicy_test2':
        ensure    => present,
        priority  => 1,
      }
    EOS

    pp2=<<-EOS
      netscaler_lbvserver_responderpolicy_bind { '1_9_lbvserver_test2/1_9_responderpolicy_test2':
        ensure    => absent,
        priority  => 1,
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
