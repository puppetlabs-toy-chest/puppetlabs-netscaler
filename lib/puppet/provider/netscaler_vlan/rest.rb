require_relative '../../../puppet/provider/netscaler'

Puppet::Type.type(:netscaler_vlan).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "vlan"
  end

  def self.instances
    instances = []
    vlans = Puppet::Provider::Netscaler.call('/config/vlan')
    return [] if vlans.nil?

    vlans.each do |vlan|
      instances << new({
        :ensure                    => :present,
        :name                      => vlan['id'],
        :alias_name                => vlan['aliasname'],
        :ipv6_dynamic_routing      => vlan['ipv6dynamicrouting'],
        :maximum_transmission_unit => vlan['mtu'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name                      => :id,
      :maximum_transmission_unit => :mtu,
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
