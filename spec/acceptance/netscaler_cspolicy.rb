require 'spec_helper_acceptance'

describe 'cspolicy' do
  before(:all) do
    pp = <<-EOS
netscaler_csaction { 'test_csaction':
  ensure               => present,
  target_lb_expression => 'http.REQ.HOSTNAME',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes a cspolicy' do
    pp=<<-EOS
netscaler_cspolicy { 'test':
  ensure      => present,
  expression  => 'HTTP.REQ.URL.PATH_AND_QUERY.CONTAINS("test")',
  action      => "test_csaction",
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'edit a cspolicy' do
    pp=<<-EOS
netscaler_cspolicy { 'test':
  ensure      => present,
  expression  => 'HTTP.REQ.URL.PATH_AND_QUERY.CONTAINS("nothing")',
  action      => "test_csaction",
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'delete a cspolicy' do
    pp=<<-EOS
netscaler_cspolicy { 'test':
  ensure => absent,
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
