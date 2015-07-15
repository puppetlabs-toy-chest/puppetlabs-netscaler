require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_rewritepolicylabel).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "rewritepolicylabel"
  end

  def self.instances
    instances = []
    rewritepolicylabels = Puppet::Provider::Netscaler.call('/config/rewritepolicylabel')
    return [] if rewritepolicylabels.nil?

    rewritepolicylabels.each do |rewritepolicylabel|
      instances << new({
        :ensure         => :present,
        :name           => rewritepolicylabel['labelname'],
        :transform_name => rewritepolicylabel['transform'],
        :comments       => rewritepolicylabel['comment'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name           => :labelname,
      :transform_name => :transform,
      :comments       => :comment,
    }
  end

  def immutable_properties
    [
      :transform_name,
      :comments, 
    ]
  end

  def per_provider_munge(message)
    message
  end
end
