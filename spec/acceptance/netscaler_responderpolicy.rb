require 'spec_helper_acceptance'

describe 'responderpolicy' do
  it 'makes a responderpolicy' do
    pp=<<-EOS
netscaler_responderpolicy { 'jim':
  ensure      => 'present',
  action      => 'NOOP',
  comments    => 'comment',
  rule        => 'ANALYTICS.STREAM("Top_CLIENTS").COLLECT_STATS',
  undefaction => 'NOOP',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
