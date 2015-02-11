require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_responderglobal).provide(:rest, parent: Puppet::Provider::NetscalerBinding) do
  def netscaler_api_type
    "responderglobal_responderpolicy_binding"
  end

  def self.instances
    instances = []
    responderpolicies = Puppet::Provider::Netscaler.call("/config/responderpolicy")
    return [] if responderpolicies.nil?

    responderpolicies.each do |policy|
      binds = Puppet::Provider::Netscaler.call("/config/responderpolicy_responderglobal_binding#{policy['name']}") || []

      binds.each do |bind|
        case bind['labeltype']
        when 'reqvserver'
          vserverlabel = bind['labelname']
        when 'resvserver'
          vserverlabel = bind['labelname']
        when 'policylabel'
          policylabel = bind['labelname']
        end
        instances << new(
          :ensure                 => :present,
          :name                   => bind['name'],
          :priority               => bind['priority'],
          :gotopriorityexpression => bind['gotopriorityexpression'],
          :invoke_policy_label    => policylabel,
          :invoke_vserver_label   => vserverlabel,
        )
      end
    end

    instances
  end

  mk_resource_methods

  def property_to_rest_mapping
    {
    }
  end

  def immutable_properties
    [
      :priority,
      :gotopriorityexpression,
      :labelType,
      :labelname,
      :policyname,
    ]
  end

  def destroy
    result = Puppet::Provider::Netscaler.delete("/config/responderglobal_responderpolicy_binding/",{'args'=>"policyname:#{resource.name}"})
    @property_hash.clear

    return result
  end

  def per_provider_munge(message)
    message[:policyname] = message[:name]
    if message[:invoke_policy_label]
      message[:labelType] = 'policylabel'
      message[:labelname] = message[:invoke_policy_label]
      message.delete(:invoke_policy_label)
    elsif message[:invoke_vserver_label]
      message[:labelType] = 'vserver'
      message[:labelname] = message[:invoke_vserver_label]
      message.delete(:invoke_vserver_label)
    end
    
    message[:invoke] = TRUE
    message.delete(:name)
    message
  end
end
