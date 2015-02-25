require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_cspolicylabel).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "cspolicylabel"
  end

  def self.instances
    instances = []
    cspolicylabels = Puppet::Provider::Netscaler.call('/config/cspolicylabel')
    return [] if cspolicylabels.nil?

    cspolicylabels.each do |cspolicylabel|
      instances << new(
        :ensure     => :present,
        :name       => cspolicylabel['labelname'],
        :label_type => cspolicylabel['cspolicylabeltype'],
      )
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name       => :labelname,
      :label_type => :cspolicylabeltype,
    }
  end

  def immutable_properties
    [
      :label_type,
    ]
  end

  def per_provider_munge(message)
    message
  end
end
