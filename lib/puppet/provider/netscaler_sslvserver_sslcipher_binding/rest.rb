require 'puppet/provider/netscaler'

require 'json'

Puppet::Type.type(:netscaler_sslvserver_sslcipher_binding).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
	def self.netscaler_api_type
    "sslvserver_sslcipher_binding"
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
          :ensure      => :present,
          :name        => "#{bind['vservername']}/#{bind['cipheraliasname']}",
          :description => bind['description'],
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
      :description,
    ]
  end

  def destroy
    vservername, cipheraliasname = resource.name.split('/')
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{vservername}", {'args'=>"cipheraliasname:#{cipheraliasname}"})
    @property_hash.clear
    return result
  end

  def per_provider_munge(message)
    message[:vservername], message[:cipheraliasname] = message[:name].split('/')
    message.delete(:name)

    message
  end
end
