require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_responderpolicy).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "responderpolicy"
  end

  def self.instances
    instances = []
    responderpolicys = Puppet::Provider::Netscaler.call('/config/responderpolicy')
    return [] if  responderpolicys.nil?

    responderpolicys.each do |responderpolicy|
      instances << new(
        :ensure                 => :present,
        :name                   => responderpolicy['name'],
        :rule                   => responderpolicy['rule'],
        :action                 => responderpolicy['action'],
        :undefaction            => responderpolicy['undefaction'],
        :comments               => responderpolicy['comment'],
        :logaction              => responderpolicy['logaction'],
        :appflowaction          => responderpolicy['appflowaction'],
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

  def immutable_properties
    []
  end

  def per_provider_munge(message)
    message
  end
end