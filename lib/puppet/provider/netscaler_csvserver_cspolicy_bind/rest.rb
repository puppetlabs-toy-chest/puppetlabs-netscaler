require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_csvserver_cspolicy_bind).provide(:rest, parent: Puppet::Provider::NetscalerBinding) do
  def netscaler_api_type
    "csvserver_cspolicy_binding"
  end

  def self.instances
    instances = []
    csvservers = Puppet::Provider::Netscaler.call("/config/csvserver")
    return [] if csvservers.nil?

    csvservers.each do |csvserver|
      binds = Puppet::Provider::Netscaler.call("/config/csvserver_cspolicy_binding/#{csvserver['name']}") || []
      binds.each do |bind|
        instances << new(
          :ensure           => :present,
          :name             => "#{bind['name']}/#{bind['policyname']}",
          :priority         => bind['priority'],
          :goto_expression  => bind['gotopriorityexpression'],
          :label_name       => bind['labelname'],
          :target_lbvserver => bind['targetlbvserver'],
        )
      end
    end

    instances
  end

  mk_resource_methods

  def property_to_rest_mapping
    {
      :goto_expression  => :gotopriorityexpression,
      :label_name       => :labelname,
      :target_lbvserver => :targetlbvserver,
    }
  end

  def per_provider_munge(message)
    message[:name], message[:policyname] = message[:name].split('/')

    if message[:label_name]
      message[:labeltype] = 'policylabel'
      message[:invoke] = 'true'
    end

    message
  end
end
