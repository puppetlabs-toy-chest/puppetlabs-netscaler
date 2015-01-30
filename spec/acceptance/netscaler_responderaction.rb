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
end
