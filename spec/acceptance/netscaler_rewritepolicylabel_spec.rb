require 'spec_helper_acceptance'

describe 'rewritepolicylabel' do
  it 'makes a rewritepolicylabel' do
    pp=<<-EOS
netscaler_rewritepolicylabel { '2_11_rewritepolicylabel_test1':
  ensure                  => 'present',
  transform_name          => 'clientless_vpn_req',
  comments                => 'comment',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'makes and deletes a rewritepolicylabel' do
    pp=<<-EOS
netscaler_rewritepolicylabel { '2_11_rewritepolicylabel_test2':
  ensure                  => 'present',
  transform_name          => 'clientless_vpn_req',
  comments                => 'comment',
}
    EOS

    pp2=<<-EOS
netscaler_rewritepolicylabel { '2_11_rewritepolicylabel_test2':
  ensure                  => 'absent',
}
    EOS

    make_site_pp(pp)
    run_device(:allow_changes => true)
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
