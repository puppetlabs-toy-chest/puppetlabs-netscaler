require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_csvserver_responderpolicy_binding).provide(:rest, parent: Puppet::Provider::NetscalerBinding) do
  def netscaler_api_type
    "csvserver_responderpolicy_binding"
  end

  def self.instances
    instances = []
    csvservers = Puppet::Provider::Netscaler.call("/config/csvserver")
    return [] if csvservers.nil?

    csvservers.each do |csvserver|
      binds = Puppet::Provider::Netscaler.call("/config/csvserver_responderpolicy_binding/#{csvserver['name']}") || []
      binds.each do |bind|
        case bind['labeltype']
          when 'reqvserver'
            vserverlabel = bind['labelname']
          when 'policylabel'
            policylabel = bind['labelname']
        end
        instances << new(
          :ensure               => :present,
          :name                 => "#{bind['name']}/#{bind['policyname']}",
          :priority             => bind['priority'],
          :goto_expression      => bind['gotopriorityexpression'],
          :invoke_policy_label  => policylabel,
          :invoke_vserver_label => vserverlabel,
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
      message[:invoke] = 'true'
      message.delete(:invoke_policy_label)
    elsif message[:invoke_vserver_label]
      message[:labeltype] = 'reqvserver'
      message[:labelname] = message[:invoke_vserver_label]
      message[:invoke] = 'true'
      message.delete(:invoke_vserver_label)
    end

    message
  end
end
