require_relative '../../../puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_responderpolicy).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "responderpolicy"
  end

  def self.instances
    instances = []
    responderpolicys = Puppet::Provider::Netscaler.call('/config/responderpolicy')
    return [] if  responderpolicys.nil?

    responderpolicys.each do |responderpolicy|
      instances << new({
        :ensure                  => :present,
        :name                    => responderpolicy['name'],
        :expression              => responderpolicy['rule'],
        :action                  => responderpolicy['action'],
        :undefined_result_action => responderpolicy['undefaction'],
        :comments                => responderpolicy['comment'],
        :log_action              => responderpolicy['logaction'],
        :appflow_action          => responderpolicy['appflowaction'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :expression              => :rule,
      :undefined_result_action => :undefaction,
      :comments                => :comment,
    }
  end

  def immutable_properties
    []
  end

  def per_provider_munge(message)
    message
  end
end
