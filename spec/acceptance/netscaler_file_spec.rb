require 'spec_helper_acceptance'

describe 'file' do
  it 'makes a file' do
    pp=<<-EOS
netscaler_file { 'file.txt':
  ensure      => 'present',
  content      => 'this is some content',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end

  it 'deletes a file' do
    pp=<<-EOS
netscaler_file { 'file.txt':
  ensure      => 'absent',
}
    EOS
    make_site_pp(pp)
    run_device(:allow_changes => true)
    run_device(:allow_changes => false)
  end
end
