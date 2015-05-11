require 'spec_helper_acceptance'

describe 'feature' do
  it 'enable features' do
    pp=<<-EOS
netscaler_feature { 'Responder':
  ensure      => 'present',
}
netscaler_feature { 'SSL Offloading':
  ensure      => 'present',
}
netscaler_feature { 'SSL VPN':
  ensure      => 'present',
}
netscaler_feature { 'Content Switching':
  ensure      => 'present',
}
netscaler_feature { 'Http DoS Protection':
  ensure      => 'present',
}
netscaler_feature { 'Priority Queuing':
  ensure      => 'present',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'disable features' do
    pp=<<-EOS
netscaler_feature { 'Responder':
  ensure      => 'absent',
}
netscaler_feature { 'SSL Offloading':
  ensure      => 'absent',
}
netscaler_feature { 'SSL VPN':
  ensure      => 'absent',
}
netscaler_feature { 'Content Switching':
  ensure      => 'absent',
}
netscaler_feature { 'Http DoS Protection':
  ensure      => 'absent',
}
netscaler_feature { 'Priority Queuing':
  ensure      => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
