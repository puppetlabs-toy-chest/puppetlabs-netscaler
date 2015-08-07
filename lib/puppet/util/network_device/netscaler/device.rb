require 'puppet/util/network_device/base'
require 'puppet/util/network_device/netscaler'
require 'puppet/util/network_device/netscaler/facts'
require 'puppet/util/network_device/transport/netscaler'

class Puppet::Util::NetworkDevice::Netscaler::Device
  attr_reader :connection
  attr_accessor :url, :transport

  def initialize(url, options = {})
    @autoloader = Puppet::Util::Autoload.new(
      self,
      "puppet/util/network_device/transport",
    )
    if @autoloader.load("netscaler")
      @transport = Puppet::Util::NetworkDevice::Transport::Netscaler.new(url,options[:debug])
    end
  end

  def facts
    @facts ||= Puppet::Util::NetworkDevice::Netscaler::Facts.new(@transport)

    return @facts.retrieve
  end
end
