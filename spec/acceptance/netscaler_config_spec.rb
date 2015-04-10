require 'spec_helper_acceptance'

describe 'config tests' do
  it 'updates a config' do
    pp=<<-EOS
netscaler_config { 'default':
  ensure   => present,
  timezone => 'GMT+01:00-CET-Europe/Andorra',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
