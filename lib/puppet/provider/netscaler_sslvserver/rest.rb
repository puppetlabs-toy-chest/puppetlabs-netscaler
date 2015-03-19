require 'puppet/provider/netscaler'

require 'json'

Puppet::Type.type(:netscaler_sslvserver).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "sslvserver_sslcertkey_binding"
  end

  def self.instances
    instances = []
    sslvservers = Puppet::Provider::Netscaler.call('/config/sslvserver')
    return [] if sslvservers.nil?

    sslvservers.each do |sslvserver|
      binds = Puppet::Provider::Netscaler.call("/config/sslvserver_sslcertkey_binding/#{sslvserver['vservername']}") || []

      binds.each do |bind|
        instances << new(
          :ensure       => :present,
          :name         => bind['vservername'],
          :certkeyname  => bind['certkeyname'],
          :crlcheck     => bind['crlcheck'],
          :ca           => bind['ca'],
          :snicert      => bind['snicert'],
          :skipcaname   => bind['skipcaname'],
          :ocspcheck    => bind['ocspcheck'],
        )
      end
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
      :certkeyname,
      :crlcheck,
      :ca,
      :snicert,
      :skipcaname,
      :ocspcheck,
    ]
  end

  def destroy
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{resource.name}", {'args'=>"certkeyname:#{resource.certkeyname}"})
    @property_hash.clear
    return result
  end

  def per_provider_munge(message)
    message
  end
end
