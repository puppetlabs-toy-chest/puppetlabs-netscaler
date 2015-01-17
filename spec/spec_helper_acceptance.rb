# Add the fixtures lib dir to RUBYLIB
$:.unshift File.join(File.dirname(__FILE__),  'fixtures', 'lib')

require 'beaker-rspec'
require 'beaker/hypervisor/netscaler' #from spec/fixtures/lib

def make_site_pp(pp, path = File.join(master['puppetpath'], 'manifests'))
  on master, "mkdir -p #{path}"
  create_remote_file(master, File.join(path, "site.pp"), pp)
  on master, "chown -R #{master['user']}:#{master['group']} #{path}"
  on master, "chmod -R 0755 #{path}"
  on master, "service #{master['puppetservice']} restart"
end

def run_device(options={:allow_changes => true})
  if options[:allow_changes] == false
    acceptable_exit_codes = 0
  else
    acceptable_exit_codes = [0,2]
  end
  on(default, puppet('device','-v','--user','root','--trace','--server',master.to_s), { :acceptable_exit_codes => acceptable_exit_codes })
end

def run_resource(resource_type, resource_title=nil)
  device_host = hosts_as('netscaler').first
  options = {:ENV => {
    'FACTER_url' => "https://nsroot:#{device_host[:ssh][:password]}@#{device_host["ip"]}/nitro/v1/"
  } }
  if resource_title
    on(default, puppet('resource', resource_type, resource_title, '--trace', options), { :acceptable_exit_codes => 0 }).stdout
  else
    on(default, puppet('resource', resource_type, '--trace', options), { :acceptable_exit_codes => 0 }).stdout
  end
end

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    if host['platform'] =~ /^el-7/
      install_puppet_from_rpm host, {:release => '7', :family => 'el'}
    elsif host['platform'].match(/^(deb|ubu)/)
      install_puppet_from_deb host, {}
    end
  end
  pp=<<-EOS
  $pkg = $::osfamily ? {
    'Debian' => 'puppetmaster',
    'RedHat' => 'puppet-server',
  }
  package { $pkg: ensure => present, }
  -> service { 'puppetmaster': ensure => running, }
  EOS
  apply_manifest_on(master,pp)
  agents.each do |host|
    sign_certificate_for(host)
  end
  #on master, "service firewalld stop"
  #foss_opts = { :default_action => 'gem_install' }
  #install_puppet(foss_opts) #installs on all hosts
  #install_pe #takes forever
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    #puppet_module_install_on(master, {:source => proj_root, :module_name => 'f5'}) #This doesn't seem to work?
    hosts.each do |host|
      if ! host['platform'].match(/netscaler/)
        scp_to host, proj_root, "#{host['distmoduledir']}/netscaler"
        on host, puppet('plugin','download','--server',master.to_s)
      end
    end
    device_conf=<<-EOS
[netscaler]
type netscaler
url https://nsroot:#{hosts_as('netscaler').first[:ssh][:password]}@#{hosts_as("netscaler").first["ip"]}/nitro/v1/
EOS
    create_remote_file(default, File.join(default[:puppetpath], "device.conf"), device_conf)
    apply_manifest("include netscaler")
    on default, puppet('device','-v','--waitforcert','0','--user','root','--server',master.to_s), {:acceptable_exit_codes => [0,1] }
    on master, puppet('cert','sign','netscaler'), {:acceptable_exit_codes => [0,24] }
  end
end
