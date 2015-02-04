require 'spec_helper_acceptance'

describe 'responderaction' do
  it 'makes a responderaction' do
    pp=<<-EOS
netscaler_responderaction { 'monkey':
  ensure            => 'present',
  comments          => 'banana',
  target            => 'bla',
  type              => 'sqlresponse_ok',
  bypasssafetycheck => 'YES',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'edit a responderaction' do
    pp=<<-EOS
netscaler_responderaction { 'edit':
  ensure            => 'present',
  comments          => 'first',
  target            => 'first',
  type              => 'sqlresponse_ok',
  bypasssafetycheck => 'YES',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)

    pp2=<<-EOS
netscaler_responderaction { 'edit':
  ensure            => 'present',
  comments          => 'second',
  target            => 'second',
  bypasssafetycheck => 'NO',
}
    EOS
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

 it 'delete a responderaction' do
    pp=<<-EOS
netscaler_responderaction { 'delete':
  ensure            => 'present',
  comments          => 'first',
  target            => 'first',
  type              => 'sqlresponse_ok',
  bypasssafetycheck => 'YES',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)

    pp2=<<-EOS
netscaler_responderaction { 'edit':
  ensure            => 'absent',
}
    EOS
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

end
