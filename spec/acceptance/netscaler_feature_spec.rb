require 'spec_helper_acceptance'

describe 'feature' do
  it 'enable features' do
    pp=<<-EOS
netscaler_feature { 'Responder':
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
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
