require_relative '../../../puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_responderaction).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "responderaction"
  end

  def self.instances
    instances = []
    responderactions = Puppet::Provider::Netscaler.call('/config/responderaction')
    return [] if responderactions.nil?

    responderactions.each do |responderaction|
      instances << new({
        :ensure              => :present,
        :name                => responderaction['name'],
        :type                => responderaction['type'],
        :expression          => responderaction['target'],
        :bypass_safety_check => responderaction['bypasssafetycheck'],
        :comments            => responderaction['comment'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :expression => :target,
      :comments   => :comment,
    }
  end

  def immutable_properties
    [
      :type
    ]
  end

  def per_provider_munge(message)
    message
  end
end
