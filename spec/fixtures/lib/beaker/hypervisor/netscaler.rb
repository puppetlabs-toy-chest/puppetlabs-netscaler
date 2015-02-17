require 'beaker/hypervisor/aws_sdk'
require 'digest'

module Beaker
  class Netscaler < Beaker::AwsSdk
    # Provision all hosts on EC2 using the AWS::EC2 API
    #
    # @return [void]
    def provision
      start_time = Time.now

      # Perform the main launch work
      launch_all_nodes()

      # Wait for each node to reach status :running
      wait_for_status(:running)

      # Wait for each node's status checks to be :ok, otherwise the netscaler
      # application (mcpd) may not be started yet
      wait_for_status_checks("ok")

      # Add metadata tags to each instance
      add_tags()

      # Grab the ip addresses and dns from EC2 for each instance to use for ssh
      populate_dns()

      #enable root if user is not root
      enable_root_on_hosts()

      # Set the hostname for each box
      #set_hostnames()

      # Configure /etc/hosts on each host
      #configure_hosts()

      @logger.notify("netscaler: Provisioning complete in #{Time.now - start_time} seconds")

      nil #void
    end

    # Waits until all boxes' status checks reach the desired state
    #
    # @param status [String] EC2 state to wait for, "ok" "initializing" etc.
    # @return [void]
    # @api private
    def wait_for_status_checks(status)
      @logger.notify("netscaler: Now wait for all hosts' status checks to reach state #{status}")
      @hosts.each do |host|
        instance = host['instance']
        name = host.name

        @logger.notify("netscaler: Wait for status check #{status} for node #{name}")

        # TODO: should probably be a in a shared method somewhere
        for tries in 1..10
          begin
            if instance.client.describe_instance_status({:instance_ids => [instance.id]})[:instance_status_set].first[:system_status][:status] == status
              # Always sleep, so the next command won't cause a throttle
              backoff_sleep(tries)
              break
            elsif tries == 10
              raise "Instance never reached state #{status}"
            end
          rescue AWS::EC2::Errors::InvalidInstanceID::NotFound => e
            @logger.debug("Instance #{name} not yet available (#{e})")
          end
          backoff_sleep(tries)
        end
      end
    end

    # Configure /etc/hosts for each node
    #
    # @return [void]
    # @api private
    #def configure_hosts
    #  @hosts.each do |host|
    #    etc_hosts = "127.0.0.1\tlocalhost localhost.localdomain\n"
    #    name = host.name
    #    domain = get_domain_name(host)
    #    ip = host['private_ip']
    #    etc_hosts += "#{ip}\t#{name} #{name}.#{domain} #{host['dns_name']}\n"
    #    @hosts.each do |neighbor|
    #      if neighbor == host
    #        next
    #      end
    #      name = neighbor.name
    #      domain = get_domain_name(neighbor)
    #      ip = neighbor['ip']
    #      etc_hosts += "#{ip}\t#{name} #{name}.#{domain} #{neighbor['dns_name']}\n"
    #    end
    #    set_etc_hosts(host, etc_hosts)
    #  end
    #end

    # Enables root for instances with custom username like ubuntu-amis
    #
    # @return [void]
    # @api private
    def enable_root_on_hosts
      @hosts.each do |host|
        enable_root(host)
      end
    end

    # Override this from hypervisor.rb
    def configure
      # do nothing
    end

    # Enables root access for a host when username is not root
    #
    # @return [void]
    # @api private
    def enable_root(host)
      host['ssh'] = {:password => host['instance'].id}
      @logger.notify("netscaler: nsroot password is #{host['instance'].id}")
      #if host['user'] != 'root'
      #  host.exec(Command.new("modify sys db systemauth.disablerootlogin value false"), :acceptable_exit_codes => [0,1])
      #  for tries in 1..10
      #    begin
      #      #This command is problematic as the netscaler is not always done loading
      #      if host.exec(Command.new("modify sys global-settings gui-setup disabled"), :acceptable_exit_codes => [0,1]).exit_code == 0 and host.exec(Command.new("save sys config"), :acceptable_exit_codes => [0,1]).exit_code == 0
      #        backoff_sleep(tries)
      #        break
      #      elsif tries == 10
      #        raise "Instance was unable to be configured"
      #      end
      #    rescue Beaker::Host::CommandFailure => e
      #      @logger.debug("Instance not yet configured (#{e})")
      #    end
      #    backoff_sleep(tries)
      #  end
      #  host['user'] = 'root'
      #  host.close
      #  sha256 = Digest::SHA256.new
      #  password = sha256.hexdigest((1..50).map{(rand(86)+40).chr}.join.gsub(/\\/,'\&\&'))
      #  host['ssh'] = {:password => password}
      #  host.exec(Command.new("echo -e '#{password}\\n#{password}' | tmsh modify auth password admin"))
      #  @logger.notify("netscaler: Configured admin password to be #{password}")
      #  host.close
      #end
    end

    # Set the hostname of all instances to be the hostname defined in the
    # beaker configuration.
    #
    # @return [void]
    # @api private
    #def set_hostnames
    #  @hosts.each do |host|
    #    host.exec(Command.new("hostname #{host.name}"))
    #  end
    #end
  end
end
