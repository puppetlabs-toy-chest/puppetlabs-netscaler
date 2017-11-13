require 'puppet/provider/netscaler'

require 'json'

Puppet::Type.type(:netscaler_sslvserver_param).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "sslvserver"
  end

  def self.instances
    instances = []
    sslvservers = Puppet::Provider::Netscaler.call('/config/sslvserver')
    return [] if sslvservers.nil?

    sslvservers.each do |sslvserver|
      instances << new({
        :ensure      => :present,
        :name        => sslvserver['vservername'],
        :ssl3        => sslvserver['ssl3'],
        :sslredirect => sslvserver['sslredirect'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name          => :vservername,
    }
  end

  def immutable_properties
    [
    ]
  end

  def destroy
    vservername = resource.name
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}", {'args'=>"vservername:#{vservername}"})
    @property_hash.clear
    return result
  end

  def per_provider_munge(message)
    message[:vservername] = message[:name]
    message.delete(:name)

    message
  end
end
