require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_lbvserver_responderpolicy_bind).provide(:rest, parent: Puppet::Provider::NetscalerBinding) do
  def netscaler_api_type
    "lbvserver_responderpolicy_binding"
  end

  def self.instances
    instances = []
    lbvservers = Puppet::Provider::Netscaler.call("/config/lbvserver")
    return [] if lbvservers.nil?

    lbvservers.each do |lbvserver|
      binds = Puppet::Provider::Netscaler.call("/config/lbvserver_responderpolicy_binding/#{lbvserver['name']}") || []
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
          :name                   => "#{bind['name']}/#{bind['policyname']}",
          :priority               => bind['priority'],
          :goto_expression        => bind['gotopriorityexpression'],
          :invoke_policy_label    => policylabel,
          :invoke_lbvserver_label => lbvserverlabel,
          :invoke_csvserver_label => csvserverlabel,
        )
      end
    end

    instances
  end

  mk_resource_methods

  def property_to_rest_mapping
    {
      :goto_expression => :gotopriorityexpression,
    }
  end

  def per_provider_munge(message)
    message[:name], message[:policyname] = message[:name].split('/')

    if message[:invoke_policy_label]
      message[:labeltype] = 'policylabel'
      message[:labelname] = message[:invoke_policy_label]
      message.delete(:invoke_policy_label)
    elsif message[:invoke_lbvserver_label]
      message[:labeltype] = 'resvserver'
      message[:labelname] = message[:invoke_lbvserver_label]
      message.delete(:invoke_lbvserver_label)
    elsif message[:invoke_csvserver_label]
      message[:labeltype] = 'reqvserver'
      message[:labelname] = message[:invoke_csvserver_label]
      message.delete(:invoke_csvserver_label)
    end

    message
  end
end
