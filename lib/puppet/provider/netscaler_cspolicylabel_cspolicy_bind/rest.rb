require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_cspolicylabel_cspolicy_bind).provide(:rest, parent: Puppet::Provider::NetscalerBinding) do
  def netscaler_api_type
    "cspolicylabel_cspolicy_binding"
  end

  def self.instances
    instances = []
    cspolicylabels = Puppet::Provider::Netscaler.call("/config/cspolicylabel")
    return [] if cspolicylabels.nil?

    cspolicylabels.each do |cspolicylabel|
      binds = Puppet::Provider::Netscaler.call("/config/cspolicylabel_cspolicy_binding/#{cspolicylabel['labelname']}") || []
      binds.each do |bind|
        instances << new(
          :ensure              => :present,
          :name                => "#{bind['labelname']}/#{bind['policyname']}",
          :priority            => bind['priority'],
          :goto_expression     => bind['gotopriorityexpression'],
          :invoke_policy_label => bind['invoke_labelname'],
          :target_lbvserver    => bind['targetvserver'],
        )
      end
    end

    instances
  end

  mk_resource_methods

  def property_to_rest_mapping
    {
      :goto_expression     => :gotopriorityexpression,
      :invoke_policy_label => :invoke_labelname,
      :target_lbvserver    => :targetvserver,
    }
  end

  def per_provider_munge(message)
    message[:labelname], message[:policyname] = message[:name].split('/')

    if message[:label_name]
      message[:labeltype] = 'policylabel'
      message[:invoke] = 'true'
    end

    message
  end
end
