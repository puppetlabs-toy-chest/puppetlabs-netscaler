require 'spec_helper_acceptance'

describe 'group_user_binding' do
#  it 'makes a group_user_binding' do
#    pp=<<-EOS
#netscaler_user { 'joe':
#  ensure                  => 'present',
#  external_authentication => 'ENABLED',
#  idle_time_out           => '900',
#  logging_privilege       => 'ENABLED',
#  password                => 'bla',
#}
#netscaler_group { 'testing':
#  ensure   => 'present',
#}
#netscaler_group_user_binding { 'testing/joe':
#  ensure  => 'present',
#}
#    EOS
#    make_site_pp(pp)
#    run_device(:allow_changes => true)
#    run_device(:allow_changes => false)
#  end
#
# it 'delete a group_user_binding' do
#    pp2=<<-EOS
#netscaler_group_user_binding { 'testing/joe':
#  ensure => 'absent',
#}
#    EOS
#    make_site_pp(pp2)
#    run_device(:allow_changes => true)
#    run_device(:allow_changes => false)
#  end
end
