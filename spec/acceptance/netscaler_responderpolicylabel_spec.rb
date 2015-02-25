require 'spec_helper_acceptance'

describe 'responderpolicylabel' do
  it 'makes a responderpolicylabel' do
    pp=<<-EOS
netscaler_responderpolicylabel { 'testresponderpolicylabel':
    ensure     => 'present',
    type       => 'NAT',
    comments   => 'comment',
  }
      EOS
      make_site_pp(pp)
      run_device(:allow_changes => true)
      run_device(:allow_changes => false)
  end

  it 'delete a responderpolicylabel' do
    pp2=<<-EOS
netscaler_responderpolicylabel { 'testresponderpolicylabel':
  ensure => 'absent',
}
    EOS
    make_site_pp(pp2)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
