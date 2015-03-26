require 'spec_helper_acceptance'

describe 'nshostname tests' do
  it 'sets an nshostname' do
    pp=<<-EOS
      netscaler_nshostname { 'testname1': }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'changes an nshostname' do
    pp=<<-EOS
      netscaler_nshostname { 'testname2': }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
