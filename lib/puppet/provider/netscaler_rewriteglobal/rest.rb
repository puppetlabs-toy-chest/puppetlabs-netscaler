require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_rewriteglobal).provide(:rest, parent: Puppet::Provider::NetscalerBinding) do
  def netscaler_api_type
    "rewriteglobal_rewritepolicy_binding"
  end

  def self.instances
    instances = []
    rewritepolicies = Puppet::Provider::Netscaler.call("/config/rewritepolicy")
    return [] if rewritepolicies.nil?

    rewritepolicies.each do |policy|
      binds = Puppet::Provider::Netscaler.call("/config/rewritepolicy_rewriteglobal_binding/#{policy['name']}") || []

      binds.each do |bind|
        case bind['labeltype']
        when 'reqvserver'
          csvserverlabel = bind['labelname']
        when 'resvserver'
          lbvserverlabel = bind['labelname']
        when 'policylabel'
          policylabel = bind['labelname']
        end
        instances << new(
          :ensure                 => :present,
          :name                   => bind['name'],
          :type                   => bind['type'],
          :priority               => bind['priority'],
          :gotopriorityexpression => bind['gotopriorityexpression'],
          :invoke_policy_label    => policylabel,
          :invoke_vserver_label => lbvserverlabel || csvserverlabel,
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
    result = Puppet::Provider::Netscaler.delete("/config/rewriteglobal_rewritepolicy_binding",{'args'=>"policyname:#{resource.name}"})
    @property_hash.clear

    return result
  end

  def per_provider_munge(message)
    message[:policyname] = message[:name]
    if message[:invoke_policy_label]
      message[:labeltype] = 'policylabel'
      message[:labelname] = message[:invoke_policy_label]
      message[:invoke] = 'true'
      message.delete(:invoke_policy_label)
    elsif message[:invoke_vserver_label]
      message[:labeltype] = 'reqvserver'
      message[:labelname] = message[:invoke_vserver_label]
      message[:invoke] = 'true'
      message.delete(:invoke_vserver_label)
    end
    
    message.delete(:name)
    message
  end
end