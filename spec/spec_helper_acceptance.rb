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
  on(default, puppet('device','--verbose','--color','false','--user','root','--trace','--server',master.to_s), { :acceptable_exit_codes => acceptable_exit_codes }) do |result|
    if options[:allow_changes] == false
      expect(result.stdout).to_not match(%r{^Notice: /Stage\[main\]})
    end
    expect(result.stderr).to_not match(%r{^Error:})
    expect(result.stderr).to_not match(%r{^Warning:})
  end
end

def device_facts_ok(max_retries)
  1.upto(max_retries) do |retries|
    on master, puppet('device','-v','--user','root','--server',master.to_s), {:acceptable_exit_codes => [0,1] } do |result|
      return if result.stdout =~ /Notice: Finished catalog run/

      counter = 10 * retries
      logger.debug "Unable to get a successful catalog run, Sleeping #{counter} seconds for retry #{retries}"
      sleep counter
    end
  end
  raise Puppet::Error, "Could not get a successful catalog run."
end

def wait_for_api(max_retries)
  1.upto(max_retries) do |retries|
    on(master, "curl -kIL https://nsroot:#{hosts_as('netscaler').first[:ssh][:password]}@#{hosts_as('netscaler').first["ip"]}/nitro/v1/config/nsconfig", { :acceptable_exit_codes => [0,1] }) do |result|
      return if result.stdout =~ /200 OK/

      counter = 10 * retries
      logger.debug "Unable to connect to Netscaler REST API, retrying in #{counter} seconds..." 
      sleep counter
    end
  end
  raise Puppet::Error, "Could not connect to API."
end

def run_resource(resource_type, resource_title=nil)
  device_host = hosts_as('netscaler').first
  options = {:ENV => {
    'FACTER_url' => "https://nsroot:#{hosts_as('netscaler').first[:ssh][:password]}@#{hosts_as('netscaler').first['ip']}/nitro/v1/"
  } }
  if resource_title
    on(default, puppet('resource', resource_type, resource_title, '--trace', options), { :acceptable_exit_codes => 0 }).stdout
  else
    on(default, puppet('resource', resource_type, '--trace', options), { :acceptable_exit_codes => 0 }).stdout
  end
end

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  if default.is_pe?
    install_pe #takes forever
  else
    hosts.each do |host|
      if host['platform'] =~ /^el-7/
        install_puppet_from_rpm host, {:release => '7', :family => 'el'}
      elsif host['platform'].match(/^(deb|ubu)/)
        install_puppet_from_deb host, {}
        # Why do we still have templatedir in the puppet.conf?
        on host, "sed -i 's/templatedir=.*//' /etc/puppet/puppet.conf"
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
  end
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
        rsync_to host, proj_root, "#{host['distmoduledir']}/netscaler", {:ignore => [".bundle"]}
        on host, puppet('plugin','download','--server',master.to_s)
      end
    end
    device_conf=<<-EOS
[netscaler]
type netscaler
url https://nsroot:#{hosts_as('netscaler').first[:ssh][:password]}@#{hosts_as('netscaler').first['ip']}/nitro/v1/
EOS
    create_remote_file(default, File.join(default[:puppetpath], "device.conf"), device_conf)
    apply_manifest("include netscaler")
    on default, puppet('device','-v','--waitforcert','0','--user','root','--server',master.to_s), {:acceptable_exit_codes => [0,1] }
    on master, puppet('cert','sign','netscaler'), {:acceptable_exit_codes => [0,24] }
    #Queries the Netscaler REST API & Puppet Master until they have been initialized
    wait_for_api(10)
    #Verify Facts can be retreived 
    device_facts_ok(3)
  end
end
