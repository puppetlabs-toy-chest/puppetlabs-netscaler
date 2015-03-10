require 'spec_helper_acceptance'

describe 'ntpsync tests' do
  it 'enables ntpsync' do
    pp=<<-EOS
      netscaler_ntpsync { 'true': }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'disables ntpsync' do
    pp=<<-EOS
      netscaler_ntpsync { 'false': }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
