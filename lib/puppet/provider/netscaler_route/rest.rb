require 'puppet/provider/netscaler'

require 'json'

Puppet::Type.type(:netscaler_route).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "route"
  end

  def self.instances
    instances = []
    #look for files at a certain location
    routes = Puppet::Provider::Netscaler.call('/config/route')
    return [] if routes.nil?

    routes.each do |route|
      instances << new({
        :ensure    => :present,
        :name      => "#{route['network']}/#{route['netmask']}:#{route['gateway']}",
        :td        => route['td'],
        :advertise => route['advertise'],
        :distance  => route['distance'],
        :cost1     => route['cost1'],
        :weight    => route['weight'],
        :protocol  => route['protocol'],
        :msr       => route['msr'],
        :monitor   => route['monitor'],
      })
    end
    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
    }
  end

  def immutable_properties
    [
    ]
  end

  def destroy
    network, netmask_gateway = resource.name.split('/')
    netmask, gateway = netmask_gateway.split(':')
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{network}", {'args'=>"netmask:#{netmask},gateway:#{gateway}"})
    @property_hash.clear
    return result
  end

  def per_provider_munge(message)
    message[:network], netmask_gateway = message[:name].split('/')
    message[:netmask], message[:gateway] = netmask_gateway.split(':')
    message.delete(:name)

    message
  end
end
