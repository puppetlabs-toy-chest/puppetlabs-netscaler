require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_rewritepolicy).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "rewritepolicy"
  end

  def self.instances
    instances = []
    rewritepolicies = Puppet::Provider::Netscaler.call('/config/rewritepolicy')
    return [] if rewritepolicies.nil?

    rewritepolicies.each do |rewritepolicy|
    instances << new({
      :ensure                  => :present,
      :name                    => rewritepolicy['name'],
      :expression              => rewritepolicy['rule'],
      :action                  => rewritepolicy['action'],
      :undefined_result_action => rewritepolicy['undefaction'],
      :comments                => rewritepolicy['comment'],
      :log_action              => rewritepolicy['logaction'],
    })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :undefined_result_action => :undefaction,
      :comments                => :comment,
      :expression              => :rule,
    }
  end

  def immutable_properties
    []
  end

  def per_provider_munge(message)
    message
  end
end
