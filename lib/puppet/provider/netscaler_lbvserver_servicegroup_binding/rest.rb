require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_lbvserver_servicegroup_binding).provide(:rest, {:parent => Puppet::Provider::NetscalerBinding}) do
  def netscaler_api_type
    "lbvserver_servicegroup_binding"
  end

  def self.instances
    instances = []
    lbvservers = Puppet::Provider::Netscaler.call("/config/lbvserver")
    return [] if lbvservers.nil?

    lbvservers.each do |lbvserver|
      binds = Puppet::Provider::Netscaler.call("/config/lbvserver_servicegroup_binding/#{lbvserver['name']}") || []
      binds.each do |bind|
        instances << new(
          :ensure => :present,
          :name   => "#{bind['name']}/#{bind['servicegroupname']}",
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

  def per_provider_munge(message)
    message[:name], message[:servicegroupname] = message[:name].split('/')

    message
  end

  def destroy
    toname, fromname = resource.name.split('/').map { |n| URI.escape(n) }
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{toname}",{'args'=>"servicegroupname:#{fromname}"})
    @property_hash.clear

    return result
  end
end
