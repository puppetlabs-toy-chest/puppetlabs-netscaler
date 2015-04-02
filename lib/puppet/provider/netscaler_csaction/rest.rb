require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_csaction).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "csaction"
  end

  def self.instances
    instances = []
    csactions = Puppet::Provider::Netscaler.call('/config/csaction')
    return [] if csactions.nil?

    csactions.each do |csaction|
      instances << new(
        :ensure               => :present,
        :name                 => csaction['name'],
        :target_lbvserver     => csaction['targetlbvserver'],
        :target_lb_expression => csaction['targetvserverexpr'],
        :comments             => csaction['comment'],
      )
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :target_lb_expression => :targetvserverexpr,
      :comments             => :comment,
    }
  end

  def immutable_properties
    [
      :type
    ]
  end

  def per_provider_munge(message)
    if (message[:target_lb_expression] and @original_values[:target_lbvserver]) or
       (message[:target_lbvserver] and @original_values[:target_lb_expression])
      fail "Cannot change csaction resource from a target lbvserver to a target lb expression or vice versa."
    end
    message
  end
end
