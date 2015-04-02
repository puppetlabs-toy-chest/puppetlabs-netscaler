require 'spec_helper_acceptance'

describe 'sslkeyfile' do
  it 'makes a sslkeyfile' do
    pp=<<-EOS
netscaler_sslkeyfile { 'monkey':
  ensure      => 'present',
  source      => 'https://raw.githubusercontent.com/3rd-Eden/FlashPolicyFileServer/master/tests/ssl/ssl.private.key',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'deletes a sslkeyfile' do
    pp=<<-EOS
netscaler_sslkeyfile { 'monkey':
  ensure      => 'absent',
  source      => 'https://raw.githubusercontent.com/3rd-Eden/FlashPolicyFileServer/master/tests/ssl/ssl.private.key',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
