require 'spec_helper_acceptance'

describe 'responderpolicy' do
  it 'makes a responderpolicy' do
    pp=<<-EOS
netscaler_responderpolicy { 'jim':
    ensure                  => 'present',
    action                  => 'NOOP',
    comments                => 'comment',
    expression              => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
    undefined_result_action => 'NOOP',
  }
      EOS
      make_site_pp(pp)
      run_device(:allow_changes => true)
      run_device(:allow_changes => false)
  end

     it 'edit a responderpolicy' do
      pp=<<-EOS
  netscaler_responderpolicy { 'edit':
    ensure                  => 'present',
    action                  => 'NOOP',
    comments                => 'comment',
    expression              => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
    undefined_result_action => 'NOOP',
  }
      EOS
      make_site_pp(pp)
      run_device(:allow_changes => true)
      run_device(:allow_changes => false)

      pp2=<<-EOS
  netscaler_responderpolicy { 'edit':
    ensure                  => 'present',
    action                  => 'NOOP',
    comments                => 'update',
    expression              => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
    undefined_result_action => 'NOOP',
  }
      EOS
      make_site_pp(pp2)
      run_device(:allow_changes => true)
      run_device(:allow_changes => false)
    end

   it 'delete a responderpolicy' do
      pp=<<-EOS
  netscaler_responderpolicy { 'delete':
    ensure                  => 'present',
    action                  => 'NOOP',
    comments                => 'comment',
    expression              => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
    undefined_result_action => 'NOOP',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)

    pp2=<<-EOS
netscaler_responderpolicy { 'delete':
  ensure => 'absent',
}
    EOS
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
