require 'spec_helper_acceptance'

describe 'csaction' do
  before(:all) do
    pp = <<-EOS
netscaler_lbvserver { 'csaction_lbvs1':
  ensure       => present,
  service_type => 'HTTP',
  ip_address   => '15.14.13.12',
  port         => '80',
}
netscaler_lbvserver { 'csaction_lbvs2':
  ensure       => present,
  service_type => 'HTTP',
  ip_address   => '15.14.13.12',
  port         => '81',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes a csaction' do
    pp=<<-EOS
netscaler_csaction { 'testexpr':
  ensure               => present,
  target_lb_expression => 'http.REQ.HOSTNAME',
}
netscaler_csaction { 'tolbvs':
  ensure           => present,
  target_lbvserver => 'csaction_lbvs1',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'edit a csaction' do
    pp=<<-EOS
netscaler_csaction { 'testexpr':
  ensure               => present,
  target_lb_expression => '"mylb_" + HTTP.REQ.URL.SUFFIX',
}
netscaler_csaction { 'tolbvs':
  ensure           => present,
  target_lbvserver => 'csaction_lbvs2',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

 it 'delete a csaction' do
    pp=<<-EOS
netscaler_csaction { 'testexpr':
  ensure => absent,
}
netscaler_csaction { 'tolbvs':
  ensure => absent,
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
