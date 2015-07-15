require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_servicegroup_lbmonitor_binding).provide(:rest, {:parent => Puppet::Provider::NetscalerBinding}) do
  def netscaler_api_type
    "servicegroup_lbmonitor_binding"
  end

  def self.instances
    instances = []
    servicegroups = Puppet::Provider::Netscaler.call("/config/servicegroup")
    return [] if servicegroups.nil?

    servicegroups.each do |servicegroup|
      binds = Puppet::Provider::Netscaler.call("/config/servicegroup_lbmonitor_binding/#{servicegroup['servicegroupname']}") || []
      binds.each do |bind|
        instances << new({
          :ensure  => :present,
          :name    => "#{bind['servicegroupname']}/#{bind['monitor_name']}",
          :weight  => bind['weight'],
          :state   => bind['monstate'],
          :passive => bind['passive'],
        })
      end
    end

    instances
  end

  mk_resource_methods

  def property_to_rest_mapping
    {
      :state          => :monstate,
    }
  end

  def per_provider_munge(message)
    message[:servicegroupname], message[:monitor_name] = message[:name].split('/')
    message.delete(:name)

    message
  end

  def destroy
    toname, fromname = resource.name.split('/').map { |n| URI.escape(n) }
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{toname}",{'args'=>"monitor_name:#{fromname}"})
    @property_hash.clear

    return result
  end
end
