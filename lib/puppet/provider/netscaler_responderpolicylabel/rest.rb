require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_responderpolicylabel).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "responderpolicylabel"
  end

  def self.instances
    instances = []
    responderpolicylabels = Puppet::Provider::Netscaler.call('/config/responderpolicylabel')
    return [] if responderpolicylabels.nil?

    responderpolicylabels.each do |responderpolicylabel|
      instances << new(
        :ensure   => :present,
        :name     => responderpolicylabel['labelname'],
        :type     => responderpolicylabel['policylabeltype'],
        :comments => responderpolicylabel['comment'],
      )
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name     => :labelname,
      :type     => :policylabeltype,
      :comments => :comment,
    }
  end

  def immutable_properties
    [
      :type,
      :comments, 
    ]
  end

  def per_provider_munge(message)
    message
  end
end
