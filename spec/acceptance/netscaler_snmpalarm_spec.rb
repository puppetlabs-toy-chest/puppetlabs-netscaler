require 'spec_helper_acceptance'

describe 'snmpalarm tests' do
  it 'enables an alarm' do
    pp=<<-EOS
      netscaler_snmpalarm { 'entity-state':
        severity         => 'critical',
        state            => true,
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'disables an alarm' do
    pp=<<-EOS
      netscaler_snmpalarm { 'entity-state':
        severity         => 'MAJOR',
        state            => false,
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'reenables an alarm' do
    pp=<<-EOS
      netscaler_snmpalarm { 'entity-state':
        severity         => 'critical',
        state            => true,
      }
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
