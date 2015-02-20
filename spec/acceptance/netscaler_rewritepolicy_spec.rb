require 'spec_helper_acceptance'

describe 'rewritepolicy' do
  it 'makes a rewritepolicy' do
    pp=<<-EOS
netscaler_rewritepolicy { '2_10_rewritepolicy_test1':
  ensure                  => 'present',
  action                  => 'NOREWRITE',
  comments                => 'comment',
  expression              => 'HTTP.REQ.URL.SUFFIX.EQ("")',
  undefined_result_action => 'DROP',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a rewritepolicy' do
    pp=<<-EOS
netscaler_rewritepolicy { '2_10_rewritepolicy_test2':
  ensure                  => 'present',
  action                  => 'NOREWRITE',
  comments                => 'comment',
  expression              => 'HTTP.REQ.URL.SUFFIX.EQ("")',
  undefined_result_action => 'DROP',
}
    EOS

    pp2=<<-EOS
netscaler_rewritepolicy { '2_10_rewritepolicy_test2':
  ensure => 'absent',
}
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
