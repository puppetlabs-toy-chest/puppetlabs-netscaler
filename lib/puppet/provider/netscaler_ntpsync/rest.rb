require 'puppet/provider/netscaler'

Puppet::Type.type(:netscaler_ntpsync).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "ntpsync"
  end

  def self.instances
    instances = []
    setting = Puppet::Provider::Netscaler.call('/config/ntpsync')
    return [] if setting.nil? or setting.empty?

    instances << new({
      :ensure => :present,
      :name   => setting['state'],
    })

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
  def per_provider_munge(message)
    message
  end
end
