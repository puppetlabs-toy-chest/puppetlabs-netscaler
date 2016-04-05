require 'puppet/provider/netscaler'

require 'json'

Puppet::Type.type(:netscaler_sslvserver_sslcertkey_binding).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
	def self.netscaler_api_type
    "sslvserver_sslcertkey_binding"
  end
  def netscaler_api_type
		self.class.netscaler_api_type
  end

  def self.instances
    instances = []
    sslvservers = Puppet::Provider::Netscaler.call('/config/sslvserver')
    return [] if sslvservers.nil?

    sslvservers.each do |sslvserver|
      binds = Puppet::Provider::Netscaler.call("/config/#{netscaler_api_type}/#{sslvserver['vservername']}") || []

      binds.each do |bind|
        instances << new({
          :ensure     => :present,
          :name       => "#{bind['vservername']}/#{bind['certkeyname']}",
          :crlcheck   => bind['crlcheck'],
          :ca         => bind['ca'],
          :snicert    => bind['snicert'],
          :skipcaname => bind['skipcaname'],
          :ocspcheck  => bind['ocspcheck'],
        })
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
      :crlcheck,
      :ca,
      :snicert,
      :skipcaname,
      :ocspcheck,
    ]
  end

  def destroy
    vservername, certkeyname = resource.name.split('/')
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{vservername}", {'args'=>"certkeyname:#{certkeyname}"})
    @property_hash.clear
    return result
  end

  def per_provider_munge(message)
    message[:vservername], message[:certkeyname] = message[:name].split('/')
    message.delete(:name)

    message
  end
end
