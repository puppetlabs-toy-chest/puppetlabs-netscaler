require 'puppet/provider/netscaler'

Puppet::Type.type(:netscaler_nshostname).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "nshostname"
  end

  def self.instances
    instances = []
    hostnames = Puppet::Provider::Netscaler.call('/config/nshostname')
    return [] if hostnames.nil?

    hostnames.each do |hostname|
      if ! hostname.empty?
        instances << new(
          :ensure     => :present,
          :name       => hostname['hostname'],
          :owner_node => hostname['ownernode'],
        )
      end
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
  def per_provider_munge(message)
    message[:hostname] = resource.name
    message
  end
end
