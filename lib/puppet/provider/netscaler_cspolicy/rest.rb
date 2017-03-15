require_relative '../../../puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_cspolicy).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "cspolicy"
  end

  def self.instances
    instances = []
    cspolicys = Puppet::Provider::Netscaler.call('/config/cspolicy')
    return [] if  cspolicys.nil?

    cspolicys.each do |cspolicy|
      instances << new({
        :ensure     => :present,
        :name       => cspolicy['policyname'],
        :action     => cspolicy['action'],
        :log_action => cspolicy['logaction'],
        :url        => cspolicy['url'],
        :domain     => cspolicy['domain'],
        :expression => cspolicy['rule'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name       => :policyname,
      :expression => :rule,
    }
  end

  def immutable_properties
    []
  end

  def per_provider_munge(message)
    message
  end
end
