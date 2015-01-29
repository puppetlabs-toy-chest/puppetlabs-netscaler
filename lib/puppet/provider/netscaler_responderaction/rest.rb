require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_responderaction).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def self.instances
    instances = []
    responderactions = Puppet::Provider::Netscaler.call('/config/responderaction')
    return [] if responderactions.nil?

    responderactions.each do |responderaction|
      instances << new(
        :ensure                 => :present,
        :name                   => responderaction['name'],
        :type                   => responderaction['type'],
        :target                 => responderaction['target'],
        :bypassSafetyCheck      => responderaction['bypasssafetycheck'],
        :comments               => responderaction['comment'],
      )
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :comments               => :comment,
    }
  end

 # def immutable_properties
 #   [
 #     :ipv6_domain,
 #     :traffic_domain_id,
 #   ]
 # end
  def per_provider_munge(message)
    if ! @create_elements
     message
    end
  end
end
